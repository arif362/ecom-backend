# frozen_string_literal: true

module Ecommerce
  module V1
    class CustomerOrders < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::CustomerOrderSerializer
      helpers Ecommerce::V1::Serializers::ReturnOrderSerializer

      helpers do
        def fetch_ongoing_statuses
          OrderStatus.select do |status|
            %w(cancelled completed in_transit_cancelled packed_cancelled returned partially_returned).
              include?(status.order_type.to_s)
          end
        end

        def cart
          @cart = Cart.find(params[:cart_id])
        rescue ActiveRecord::RecordNotFound => error
          Rails.logger.error "\n#{__FILE__}\nUnable to find cart due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.cart_not_found'),
                                            HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
        end

        def check_zero_item(cart)
          cart.shopoth_line_items.map(&:quantity).all?(&:positive?)
        end

        def fetch_warehouse(new_address, shipping_address, shipping_type, partner = '')
          if shipping_type == 'pick_up_point'
            partner.route.warehouse
          else
            params[:new_address].present? ? District.find_by(id: new_address[:district_id])&.warehouse : shipping_address&.district&.warehouse
          end
        end

        def member_discount(user_domain, partner)
          return unless user_domain.present?

          partner.present? ? partner : nil
        end

        def validate_emi_availability(cart, shipping_type)
          minimum_price = Configuration.find_by(key: 'minimum_price_to_avail_emi')&.value
          if cart.shopoth_line_item_total < minimum_price
            minimum_price = I18n.locale == :bn ? minimum_price.to_i.to_s.to_bn : minimum_price.to_i
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.minimum_price_to_avail_emi', minimum_price: minimum_price),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          unless Configuration.find_by(key: 'emi_available_shipping').version_config[shipping_type.to_sym]
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.emi_unavailable_shipping', shipping: shipping_type),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          return if cart.emi_applicable?(params[:tenure])

          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.emi_not_applicable'),
                                            HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
        end
      end

      resource :customer_orders do
        desc "Show logged in user's customer orders."
        params do
          use :pagination, per_page: 50
        end
        get '/my-orders' do
          # TODO: Need to Optimize Query
          response = if params[:status] == 'returned'
                       all_orders = @current_user.aggregate_returns.includes(:return_customer_orders,
                                                                             customer_order: :status)
                       Ecommerce::V1::Entities::AggregateReturns.represent(
                         paginate(Kaminari.paginate_array(all_orders.order(id: :desc))), list: true
                       )
                     else
                       all_orders = @current_user.customer_orders.includes(:status)
                       if params[:status].present?
                         all_orders = all_orders.where(status: OrderStatus.status(params[:status]))
                       end
                       Ecommerce::V1::Entities::CustomerOrders.represent(
                         paginate(Kaminari.paginate_array(all_orders.order(id: :desc))),
                       )
                     end
          success_response_with_json(I18n.t('Ecom.success.messages.order_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.info "ecom: my orders fetch error due to #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.order_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:OK])
        end

        # NOT USED AT ALL IN V2
        desc 'Show Customer Ongoing Orders'
        get '/ongoing-orders' do
          cancelled_statuses = fetch_ongoing_statuses
          get_customer_orders @current_user.customer_orders.where.
            not(status: cancelled_statuses).includes(:status).order(id: :desc)
        rescue StandardError => error
          error!("Unable to fetch due to #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # NOT USED AT ALL IN V2
        desc 'Show cancelled orders'
        get '/cancelled-orders' do
          cancelled_status_ids = OrderStatus.where(order_type: %w(cancelled in_transit_cancelled)).ids
          get_customer_orders @current_user.customer_orders.
            where(order_status_id: cancelled_status_ids).includes(:status).order(id: :desc)
        rescue StandardError => error
          error!("Unable to fetch due to #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # NOT USED AT ALL IN V2
        desc 'Show completed orders'
        get '/completed-orders' do
          statuses = %i(completed partially_returned returned)
          completed_status_id = OrderStatus.fetch_statuses(statuses).ids
          get_customer_orders CustomerOrder.completed_orders(@current_user.id, completed_status_id).
            includes(:status).order(id: :desc)
        rescue StandardError => error
          error!("Unable to fetch due to #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Show Details of One Customer Order'
        route_param :id do
          get do
            order = CustomerOrder.includes(:customer, :status,
                                           shopoth_line_items: [variant: { product: :main_image_attachment }],
                                           partner: { address: %i(district thana area) }).
                    find_by!(id: params[:id], customer_id: @current_user.id)
            success_response_with_json(I18n.t('Ecom.success.messages.order_fetch_successful'),
                                       HTTP_CODE[:OK],
                                       Ecommerce::V1::Entities::CustomerOrderDetails.represent(order))
          rescue StandardError => error
            Rails.logger.info "ecom: my orders fetch error due to #{error.message}"
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.order_fetch_failed'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Create Order with Cart Items.'
        params do
          requires :cart_id, type: Integer
          requires :shipping_type, type: String
          optional :full_name, type: String
          optional :phone, type: String
          optional :new_address, type: Hash do
            requires :district_id, type: Integer
            requires :thana_id, type: Integer
            requires :area_id, type: Integer
            # Due to frontend requirement I had to take input full_name and phone twice (for pick_up_point and home_delivery and express_delivery) in the params.
            requires :full_name, type: String
            requires :phone, type: String
            requires :home_address, type: String
            optional :alternative_phone, type: String
            optional :post_code, type: Integer
            optional :title, type: String, default: 'others'
            optional :remember, type: Boolean
          end
          optional :partner_id, type: Integer
          optional :rider_id, type: Integer
          optional :billing_address_id, type: Integer
          optional :shipping_address_id, type: Integer
          requires :form_of_payment, type: String
          optional :domain, type: String
          optional :customer_device_id, type: Integer
          optional :tenure, type: Integer
        end
        post do
          shipping_address = if params[:shipping_address_id].present? && params[:shipping_type] != 'pick_up_point'
                               shipping_address = Address.find_by(id: params[:shipping_address_id])
                               unless shipping_address
                                 error!(failure_response_with_json(I18n.t('Ecom.errors.messages.address_not_found'),
                                                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
                               end
                               shipping_address
                             end

          phone = if params[:shipping_type] == 'pick_up_point'
                    params[:phone].to_s.bd_phone
                  else
                    params[:new_address].present? ? params[:new_address][:phone].to_s.bd_phone : shipping_address&.phone
                  end

          unless phone
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.phone_number_not_valid'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          current_cart = cart

          unless current_cart
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.cart_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          unless check_zero_item(current_cart)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.valid_quantity'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          if params[:form_of_payment] == 'emi_payment'
            validate_emi_availability(current_cart, params[:shipping_type])
          end

          if params[:shipping_type] == 'pick_up_point'
            partner = Partner.active.find_by(id: params[:partner_id])
            unless partner
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.partner_not_found'),
                                                HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end

            # if partner.phone == params[:phone]
            #   error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_and_partner_phone_same'),
            #                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            # end
          end

          warehouse = fetch_warehouse(params[:new_address], shipping_address, params[:shipping_type], partner)
          warehouse_id = warehouse.id
          unless warehouse
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.warehouse_not_found'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          item_errors = current_cart.validate_cart_items_price(warehouse_id)
          if item_errors.size.positive?
            error!(failure_response_with_json("Please remove #{item_errors}",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:OK])
          end
          unless current_cart.check_minimum_cart_value
            min_cart_value = I18n.locale == :bn ? Configuration.find_by(key: 'min_cart_value')&.value.to_i.to_s.to_bn : Configuration.find_by(key: 'min_cart_value')&.value.to_i
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.minimum_cart_value', min_cart_value: min_cart_value),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          products = WarehouseVariant.stock_availability(current_cart, warehouse_id)
          unless products[:available]
            error!(failure_response_with_json("#{products[:items].join(',')} are stock out!",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          product_visibility = current_cart.products_visible?
          unless product_visibility.all?(true)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.product_visibility'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          less_than_max_quantity = current_cart.check_products_max_limit
          unless less_than_max_quantity.all?(true)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.max_limit_exceed'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          coupon = nil
          if current_cart.coupon_code.present?
            coupon = Coupon.unused.find_by(code: current_cart.coupon_code)
            unless coupon
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
            if cart.sub_total - cart.cart_discount < 180
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.min_cart_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            c_order = CustomerOrder.find_by(coupon_code: coupon.code)
            if c_order.present? && !coupon.first_registration? && !coupon.multi_user?
              Rails.logger.info "coupon already applied in order #{c_order.id}"
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
            unless coupon.check_phone_numbers(@current_user)
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            if coupon.skus.present? && coupon.coupon_category.present? &&
               coupon.valid_for_category(cart) == false
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            if (coupon.skus.present? || coupon.coupon_category.present?) &&
               (coupon.valid_for_category(cart) == false && coupon.check_sku(cart) == false)
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            if coupon.aggregate_return_id.blank? && coupon.return_customer_order_id.blank? && coupon.promo_coupon.blank? && !coupon.promotion&.running? && !coupon.valid_for_first_time?(@current_user) && !coupon.valid_for_multi_user?(@current_user)
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end
          if params[:customer_device_id].present?
            customer_device = CustomerDevice.find_by(id: params[:customer_device_id])
            unless customer_device
              error!(failure_response_with_json('CustomerDevice not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
          end

          order_context = OrderManagement::CreateCustomerOrder.call(
            customer: @current_user,
            cart: current_cart,
            billing_address_id: params[:billing_address_id].to_i,
            shipping: shipping_address,
            shipping_type: params[:shipping_type],
            full_name: params[:full_name],
            phone: params[:phone],
            new_address: params[:new_address],
            form_of_payment: params[:form_of_payment],
            partner: partner,
            customer_orderable: @current_user,
            order_type: 'organic',
            domain: member_discount(user_domain, partner),
            warehouse_id: warehouse_id,
            platform: @request_source,
            customer_device_id: params[:customer_device_id],
            coupon: coupon,
            tenure: params[:tenure],
          )

          if order_context.success?
            CreateNotification.call(
              user: order_context.order.customer,
              message: Notification.get_notification_message(order_context.order),
              order: order_context.order,
            )

            SendSmsJob.perform_later(order_context.order)

            success_response_with_json(I18n.t('Ecom.success.messages.customer_order_create_successful'),
                                       HTTP_CODE[:OK], order_context.order.as_json(only: %i(id pay_type total_price)))
          else
            error!(failure_response_with_json(order_context.error&.to_s, HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
        rescue ActiveRecord::RecordNotFound => error
          Rails.logger.error "\n#{__FILE__}\nEcom_customer_orders Record not found error: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.customer_order_record_not_found'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.info "\n#{__FILE__}\nUnable to create customer order due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.customer_order_creation_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
