module ShopothPartner
  module V1
    class Orders < ShopothPartner::Base
      helpers do
        def calculate_commission(user)
          @cart.update(user: user)
          commission = 0.0
          @cart.shopoth_line_items.each do |line_item|
            variant = line_item.variant
            retailer_price = variant.price_retailer || 0
            consumer_price = variant.price_consumer || 0
            commission += (consumer_price - retailer_price) * line_item.quantity
          rescue => error
            error! respond_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          commission.floor
        end

        def check_zero_item(cart)
          cart.shopoth_line_items.map(&:quantity).all?(&:positive?)
        end

        def phone_validation(phone)
          partner = Partner.find_by(phone: @current_partner&.phone) if @current_partner.present?
          partner_phone = partner&.phone if partner
          retailer = RetailerAssistant.find_by(phone: @current_retailer&.phone) if @current_retailer.present?
          retailer_phone = retailer&.phone if retailer
          false if partner_phone == phone || retailer_phone == phone || partner_phone == retailer_phone
        end

        def fetch_new_address_params(user, params)
          new_address = {}
          new_address[:full_name] = if params[:first_name].present? || params[:last_name].present?
                                      [params[:first_name].strip, params[:last_name].strip].join(' ')
                                    elsif check_b2b?
                                      user.name
                                    else
                                      user.first_name
                                    end

          new_address[:phone] = user.phone
          new_address
        end

        def current_partner_cart
          check_b2b? ? @current_partner.carts.b2b.last : @current_partner.carts.b2c.last
        end
      end

      resource :order do
        desc 'Place Order from partner or retailer App.'
        params do
          optional :phone, type: String
          optional :first_name, type: String
          optional :last_name, type: String
          optional :pay_type, type: String, values: %w(nagad_payment cash_on_delivery)
        end

        route_setting :authentication, type: 'Both'
        post '/place' do
          unless @current_partner.active?
            error!(respond_with_json('You are not permitted to place order', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          @cart = current_partner_cart
          unless check_zero_item(@cart)
            error! respond_with_json(I18n.t('Partner.errors.messages.zero_quantity_for_order_place'), HTTP_CODE[:NOT_ACCEPTABLE])
          end

          user = check_b2b? ? @current_partner : User.find_by!(phone: params[:phone])
          user.update!(is_otp_verified: true, verifiable: @current_retailer.present? ? @current_retailer : @current_partner, verified_at: Time.now) unless check_b2b?
          new_address = fetch_new_address_params(user, params)
          # if phone_validation(user.phone) == false
          #   error! respond_with_json(I18n.t('Partner.errors.messages.phone_number_same'),
          #                            HTTP_CODE[:UNPROCESSABLE_ENTITY])
          # end
          warehouse = @current_partner.route.warehouse_id
          item_errors = @cart.validate_cart_items_price(warehouse, @business_type)
          if item_errors.size.positive?
            error!(respond_with_json("Please remove #{item_errors}",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:OK])
          end
          unless @cart.check_minimum_cart_value
            error!(respond_with_json(I18n.t('Partner.errors.messages.less_cart_value'), HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          products = WarehouseVariant.stock_availability(@cart, warehouse)
          unless products[:available]
            error!(respond_with_json("#{products[:items].join(',')} are stock out!", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          product_visibility = @cart.products_visible?
          unless product_visibility.all?(true)
            error!(respond_with_json(I18n.t('Ecom.errors.messages.product_visibility'),
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          less_than_max_quantity = @cart.check_products_max_limit
          unless less_than_max_quantity.all?(true)
            error!(respond_with_json(I18n.t('Ecom.errors.messages.max_limit_exceed'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          coupon = nil
          if @cart.coupon_code.present?
            coupon = Coupon.unused.find_by(code: @cart.coupon_code)
            unless coupon
              error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
            if @cart.sub_total - @cart.cart_discount < 180
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.min_cart_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
            unless coupon.check_phone_numbers(user)
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
            if coupon.skus.present? && coupon.coupon_category.present? &&
               coupon.valid_for_category(@cart) == false
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
            if (coupon.skus.present? || coupon.coupon_category.present?) &&
               (coupon.valid_for_category(@cart) == false && coupon.check_sku(@cart) == false)
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
            c_order = CustomerOrder.find_by(coupon_code: coupon.code)
            if c_order.present? && !coupon.first_registration? && !coupon.multi_user?
              Rails.logger.info "coupon already applied in order #{c_order.id}"
              error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
            co = CustomerOrder.find_by(coupon_code: @cart.coupon_code)
            @cart.update_columns(cart_discount: 0, coupon_code: nil, promotion_id: nil) if co.present?
            if coupon.aggregate_return_id.blank? && coupon.return_customer_order_id.blank? && coupon.promo_coupon.blank? && !coupon.promotion&.running? && !coupon.valid_for_first_time?(user) && !coupon.valid_for_multi_user?(user)
              error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end

          order_context = OrderManagement::CreateCustomerOrder.call(
            customer: user,
            cart: @cart,
            partner: @current_partner,
            address: @current_partner&.address,
            billing_address_id: @current_partner&.address&.id,
            shipping_address_id: @current_partner&.address&.id,
            shipping_type: 'pick_up_point',
            full_name: new_address[:full_name],
            phone: new_address[:phone],
            new_address: new_address,
            form_of_payment: params[:pay_type].present? ? params[:pay_type] : :cash_on_delivery,
            order_type: 'induced',
            customer_orderable: @current_retailer.present? ? @current_retailer : @current_partner,
            warehouse_id: warehouse,
            domain: member_partner,
            platform: 'app',
            coupon: coupon,
            business_type: @business_type
          )

          if order_context.success?
            app_notification = check_b2b? ? AppNotification.b2b_order_placed_notification(order_context.order) : AppNotification.order_placed_notification(order_context.order)
            attributes = @locale == :bn ? get_hash(app_notification[:bn_title], app_notification[:bn_message]) : get_hash(app_notification[:title], app_notification[:message])

            unless check_b2b?
              SendSmsJob.perform_later(order_context.order)
              CreateNotification.call(
                user: order_context.order.customer,
                message: Notification.get_notification_message(order_context.order),
                order: order_context.order,
              )
              PushNotification::CreateAppNotificationsPartner.call(
                app_user: @current_partner,
                title: app_notification[:title],
                bn_title: app_notification[:bn_title],
                message: app_notification[:message],
                bn_message: app_notification[:bn_message],
                attributes: attributes,
              )
            end
            present order_context.order, with: ShopothPartner::V1::Entities::CustomerOrders
          else
            error!(order_context.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to place order due to: #{error.full_message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.order_place_failed'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Order statement.'
        params do
          optional :start_date, type: Date, allow_blank: false
          optional :end_date, type: Date, allow_blank: false
        end
        get 'statement' do
          customer_orders = @current_partner.customer_orders
          statement = OrderManagement::Statement.call(orders: customer_orders, params: params)
          statement.response_hash if statement.success?
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to fetch statement due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.statement_fetch_failed'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Partner payment.'
        params do
          optional :month, type: Integer
          optional :year, type: Integer
        end
        get 'payments' do
          customer_orders = @current_partner.customer_orders
          partner_payment = OrderManagement::PartnerPayment.call(orders: customer_orders, params: params)
          partner_payment.payout_hash if partner_payment.success?
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to fetch payments due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.payment_list_fetch_failed'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
