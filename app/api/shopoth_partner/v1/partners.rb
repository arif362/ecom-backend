# frozen_string_literal: true

module ShopothPartner
  module V1
    class Partners < ShopothPartner::Base
      PARCEL_HOLDING_FEE = 15
      helpers do
        def update_order(order)
          order.update!(pay_status: :customer_paid,
                        status: OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]),
                        is_customer_paid: true,
                        changed_by: @current_partner,
                        completed_at: Time.now)
        end

        def select_products(warehouse, search_key)
          warehouse.products&.publicly_visible&.includes(:variants, :brand, :main_image_attachment, :images_attachments).where(business_type: business_types).
                   where('warehouse_variants.available_quantity > 0 AND (LOWER(products.title) LIKE :key OR LOWER(products.bn_title) LIKE :key)', key: "#{search_key&.downcase}%").uniq.sample(10)
        end

        def business_types
          return %w(b2b both) if check_b2b?

          %w(b2c both)
        end

        def update_warehouse_variant_quantity(customer_order)
          items = customer_order.shopoth_line_items
          wh_variants = WarehouseVariant.group_by_wh_variant(items, @current_partner.route.warehouse.id)
          wh_variants.each do |wh_v|
            if (wh_v['wv_id'].in_transit_quantity - wh_v['qty']).negative?
              Rails.logger.error "\nIn_transit_quantity is being negative for warehouse_variant_id: #{wh_v['wv_id'].id}.
              Action: Partner -> Collect orders from SR customer order: #{wh_v['stock_changeable'].id}\n"
            end
            if customer_order.b2b?
              wh_v['wv_id'].update!(in_transit_quantity: wh_v['wv_id'].in_transit_quantity - wh_v['qty'])
              wh_v['wv_id'].save_stock_change('customer_order_completed', wh_v['qty'], wh_v['stock_changeable'],
                                              'in_transit_quantity_change', nil)
            else
              wh_v['wv_id'].update!(in_transit_quantity: wh_v['wv_id'].in_transit_quantity - wh_v['qty'],
                                    in_partner_quantity: wh_v['wv_id'].in_partner_quantity + wh_v['qty'])
              wh_v['wv_id'].save_stock_change('customer_order_in_partner', wh_v['qty'], wh_v['stock_changeable'],
                                              'in_transit_quantity_change', 'in_partner_quantity_change')
            end
          end
        end

        def update_warehouse_variant_in_partner_quantity(customer_order)
          items = customer_order.shopoth_line_items
          wh_variants = WarehouseVariant.group_by_wh_variant(items, @current_partner.route.warehouse.id)
          wh_variants.each do |wh_v|
            if (wh_v['wv_id'].in_partner_quantity - wh_v['qty']).negative?
              Rails.logger.error "\nIn_partner_quantity is being negative for warehouse_variant_id: #{wh_v['wv_id'].id}.
              Action: Partner -> Order deliver to customer, customer order: #{wh_v['stock_changeable'].id}\n"
            end
            wh_v['wv_id'].update!(in_partner_quantity: wh_v['wv_id'].in_partner_quantity - wh_v['qty'])
            wh_v['wv_id'].save_stock_change('customer_order_completed', wh_v['qty'], wh_v['stock_changeable'],
                                            'in_partner_quantity_change', nil)
          end
        end

        def update_payment(order)
          total_amount = 0
          unless order.is_customer_paid?
            paid_amount = order.payments&.where(status: :successful, paymentable: order.customer)&.sum(:currency_amount)
            total_amount = order.total_price - paid_amount
          end

          if total_amount.positive? || order.payments.find_by(receiver_type: 'Partner').nil?
            order.customer.payments.create!(currency_amount: total_amount,
                                            currency_type: 'BDT',
                                            status: :successful,
                                            customer_order_id: order.id,
                                            receiver_id: @current_partner.id,
                                            receiver_type: @current_partner.class.to_s)
          end

        end

        def create_partner_margin(partner, order)
          partner.partner_margins.find_or_create_by(customer_order: order,
                                                    order_type: order.order_type,
                                                    margin_amount: calculate_amount(order, partner))
        end

        def calculate_amount(order, partner)
          return 0 unless partner.is_commission_applicable?

          if order.organic?
            15
          else
            order.b2b? ? 0 : induce_partner_margin(order)
          end
        end

        def induce_partner_margin(order)
          if order.return_coupon?
            order.cart_total_price * 0.05
          else
            commissionable_amount = order.cart_total_price - order.total_discount_amount
            commissionable_amount.negative? ? 0 : commissionable_amount * 0.05
          end
        end

        def send_message(customer_order)
          I18n.locale = :bn
          message = I18n.t('partner_delivered', customer_name: customer_order.name,
                                                order_id: customer_order.backend_id,
                                                total_price: customer_order.total_price.to_i,
                                                outlet_name: @current_partner.name,
                                                pin: customer_order.pin)
          SmsManagement::SendMessage.call(phone: customer_order.phone, message: message)
        end
      end

      resource '/' do
        desc 'Log a shopoth_partner'
        route_setting :authentication, optional: true
        post '/login' do
          params do
            requires :phone, type: String
            requires :password, type: String
          end
          partner = Partner.active.find_by(phone: params[:phone])
          ra = RetailerAssistant.active.find_by(phone: params[:phone])
          if partner.present? && partner&.valid_password?(params[:password])
            partner.create_app_config() if partner.app_config.nil?
            partner.app_config.update!(fcm_token: request.headers['Fcm-Token']) if request.headers['Fcm-Token'].present?
            status :ok
            {
              type: 'partner',
              auth_token: JsonWebToken.encode(partner_id: partner.id, type: 'Partner'),
              partner_name: partner&.name,
              partner_code: partner&.partner_code,
              retailer_code: partner&.retailer_code,
              bkash_number: partner&.bkash_number,
              business_type: partner&.business_type
            }
          elsif ra && ra&.valid_password?(params[:password])
            ra.create_app_config() if ra.app_config.nil?
            ra.app_config.update!(fcm_token: request.headers['Fcm-Token']) if request.headers['Fcm-Token']
            status :ok
            {
              type: 'ra',
              auth_token: JsonWebToken.encode(retailer_id: ra.id, type: 'RetailerAssistant'),
            }
          else
            Rails.logger.info 'Invalid phone or password.'
            status :unprocessable_entity
            {
              error: I18n.t('Partner.errors.messages.login'),
            }
          end
        end

        desc 'Get Partner balance.'
        get '/balance' do
          if @current_partner.wallet.present?
            status :ok
            {
              success: true,
              balance: 0,
              # balance: @current_partner.wallet.currency_amount,
            }
          else
            Rails.logger.info 'Partner or Wallet not present.'
            status :unprocessable_entity
            {
              success: false,
              # error: I18n.t('Partner.errors.messages.get_balance'),
              # TODO: Need to unhidden upper error message and hide lower error message.
              error: I18n.t('Partner.errors.messages.settings'),
            }
          end
        end

        desc 'Get partner app version config.'
        route_setting :authentication, optional: true
        get '/app_config' do
          Configuration.return_app_version_config('partner_app')
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nPartner app version config fetch failed due to: #{error.message}"
          error!(respond_with_json('Partner app version config fetch failed.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Partner Settings.'
        get '/settings' do
          if @current_partner.wallet.present?
            status :ok
            {
              success: true,
              phone: @current_partner.phone,
              balance: 0,
              # balance: @current_partner.wallet.currency_amount,
            }
          else
            Rails.logger.info 'Partner not present.'
            status :unprocessable_entity
            {
              success: false,
              error: I18n.t('Partner.errors.messages.settings'),
            }
          end
        end

        desc 'Fetch Order Received History.'
        get '/order_received_history' do
          customer_orders = @current_partner.customer_orders
          return [] unless customer_orders.present?

          orders = customer_orders.select do |order|
            order.pick_up_point? && order.status.delivered_to_partner?
          end

          status :ok
          prepare_order_history(orders)
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to fetch order received history due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.order_received_history'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Fetch Order Delivered History.'
        get '/order_delivered_history' do
          customer_orders = @current_partner.customer_orders
          return [] unless customer_orders.present?

          orders = customer_orders.select do |order|
            order.pick_up_point? && order.status.completed?
          end

          status :ok
          prepare_order_history(orders)
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to fetch order delivered history due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.order_delivered_history'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Fetch Order Payment History.'
        get 'payment_history' do
          customer_orders = @current_partner.customer_orders
          return [] unless customer_orders.present?

          selected_orders = customer_orders.where(shipping_type: 'pick_up_point')
          orders = selected_orders.select do |order|
            partner_commission = 0
            # partner_commission = order&.induced? ? order&.partner_commission.to_f : 0
            order_price = order.total_price - partner_commission
            order.partner_paid? && (order_price.to_d <= order.payments.where(status: :successful)&.sum(:currency_amount))
          end

          status :ok
          prepare_order_history(orders)
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to fetch payment history due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.order_payment_history'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Fetch Order Payment History.'
        get 'order_return_history' do
          return_orders = @current_partner.return_customer_orders
          return [] unless return_orders.present?

          status = %w(in_transit delivered_to_dh)
          selected_orders = return_orders.where(return_status: status)
          prepare_return_history(selected_orders)
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to fetch return history due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.return_history_fetch_failed'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Customer Order Parcel List'
        get 'parcel' do
          status = %w(ready_to_shipment in_transit in_transit_partner_switch delivered_to_partner completed)
          pay_status = %w(non_extended extended partner_paid customer_paid)
          customer_orders = @current_partner.customer_orders.select do |order|
            (status.include?(order.status.order_type.to_s) && pay_status.include?(order.pay_status.to_s)) || order.b2b?
          end

          present customer_orders.sort, with: ShopothPartner::V1::Entities::ParcelOrderDetails
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to find parcel list due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.parcel_list'), HTTP_CODE[:NOT_FOUND]),
                 HTTP_CODE[:NOT_FOUND])
        end

        desc 'Return Pending Payment List.'
        get 'payments/pending' do
          status = %w(delivered_to_partner completed)
          customer_orders = @current_partner.customer_orders.select do |order|
            paid_amount = order&.payments&.where(status: :successful, paymentable_type: 'Partner')&.sum(:currency_amount)
            partner_commission = 0
            # partner_commission = order&.induced? ? order&.partner_commission.to_f : 0
            order_price = order&.total_price.to_f - partner_commission
            status.include?(order&.status&.order_type) &&
              paid_amount < order_price.to_d
          end

          present customer_orders.sort, with: ShopothPartner::V1::Entities::PaymentPendingOrderDetails
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to fetch Payment list due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.payment_list_fetch_failed'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Order Details.'
        route_param :id do
          get 'history/order_details' do
            order = @current_partner.customer_orders.find(params[:id])
            if @locale == :bn
              present order, with: ShopothPartner::V1::Entities::BnOrderDetails
            else
              present order, with: ShopothPartner::V1::Entities::OrderDetails
            end
          rescue StandardError => error
            Rails.logger.info "#{__FILE__} \nUnable to fetch customer order details due to: #{error.message}"
            error!(respond_with_json(I18n.t('Partner.errors.messages.order_details'), HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        end

        desc 'Get SR phone number.'
        get '/sr_phone' do
          if @current_partner&.route&.phone.present?
            status :ok
            {
              success: true,
              sr_phone: @current_partner&.route&.phone,
            }
          else
            Rails.logger.info 'SR phone number not set.'
            status :not_found
            {
              success: false,
              error: I18n.t('Partner.errors.messages.sr_phone_not_set'),
            }
          end
        rescue StandardError => error
          Rails.logger.info "Unable to get SR phone due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.sr_phone'), HTTP_CODE[:NOT_FOUND]),
                 HTTP_CODE[:NOT_FOUND])
        end

        # desc 'Send money to SR'
        # post '/send_money' do
        #   params do
        #     requires :amount, type: Integer
        #     requires :partner_pin, type: String
        #   end
        #
        #   if @current_partner&.valid_password?(params[:partner_pin])
        #     route_wallet = @current_partner.route.wallet
        #     partner_wallet = @current_partner.wallet
        #     if route_wallet.present? && partner_wallet.currency_amount >= params[:amount]
        #       @current_partner.payments.create(currency_amount: params[:amount],
        #                                        currency_type: 'BDT',
        #                                        status: :successful,
        #                                        form_of_payment: :wallet)
        #       route_wallet.update(currency_amount: (route_wallet.currency_amount + params[:amount]))
        #       partner_wallet.update(currency_amount: (partner_wallet.currency_amount - params[:amount]))
        #       status :ok
        #       {
        #         success: true,
        #         message: 'Send money to SR successful',
        #       }
        #     elsif route_wallet.present?
        #       status :not_found
        #       {
        #         success: false,
        #         error: 'Insufficient balance',
        #       }
        #     else
        #       status :not_found
        #       {
        #         success: false,
        #         error: 'SR wallet not present',
        #       }
        #     end
        #   else
        #     status :unprocessable_entity
        #     {
        #       success: false,
        #       error: 'Invalid partner pin',
        #     }
        #   end
        # rescue => error
        #   error! respond_with_json("Unable to send money due to #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        # end

        # desc 'Payment in cash'
        # post '/cash_payment' do
        #   params do
        #     requires :amount, type: Integer
        #     requires :order_id, type: Integer
        #   end
        #   customer_order = CustomerOrder.find(params[:order_id])
        #   @current_partner.payments.create(currency_amount: params[:amount],
        #                                    currency_type: 'BDT',
        #                                    status: :successful,
        #                                    form_of_payment: :cash)
        #
        #   customer_order.update(pay_status: :partner_paid)
        #   status :ok
        #   {
        #     success: true,
        #     message: 'Cash Payment to SR successful',
        #   }
        # rescue => error
        #   error! respond_with_json("Unable to do cash payment due to #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        # end

        # desc 'Payment through wallet'
        # post '/wallet_payment' do
        #   params do
        #     requires :wallet_amount, type: Integer
        #     requires :order_id, type: Integer
        #     requires :partner_pin, type: String
        #   end
        #   if @current_partner&.valid_password?(params[:partner_pin])
        #     customer_order = CustomerOrder.find(params[:order_id])
        #     route_wallet = @current_partner.route.wallet
        #     partner_wallet = @current_partner.wallet
        #     if route_wallet.present? && partner_wallet.currency_amount >= params[:wallet_amount]
        #       paid_amount = customer_order&.payments&.where(status: :successful, paymentable_type: 'Partner')&.sum(:currency_amount)
        #       partner_commission = customer_order.induced? ? customer_order.partner_commission.to_f : 0
        #       order_price = customer_order.total_price - partner_commission
        #
        #       @current_partner.payments.create(currency_amount: params[:wallet_amount],
        #                                        currency_type: 'BDT',
        #                                        status: :successful,
        #                                        form_of_payment: :wallet,
        #                                        customer_order_id: params[:order_id])
        #
        #       route_wallet.update(currency_amount: (route_wallet.currency_amount + params[:wallet_amount]))
        #       partner_wallet.update(currency_amount: (partner_wallet.currency_amount - params[:wallet_amount]))
        #       if (order_price.to_d - paid_amount) <= params[:wallet_amount]
        #         if customer_order.extension_expired?
        #           customer_order.update(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:sold_to_partner]),
        #                                 changed_by: @current_partner)
        #         end
        #         customer_order.update(pay_status: :partner_paid)
        #       end
        #       app_notification = AppNotification.money_transaction_notification(customer_order, params[:wallet_amount], 'wallet')
        #       PushNotification::CreateAppNotifications.call(
        #         app_user: @current_partner.route,
        #         title: app_notification[:title],
        #         message: app_notification[:message])
        #
        #       status :ok
        #       {
        #         success: true,
        #         message: 'Wallet Payment to SR successful',
        #       }
        #     elsif route_wallet.present?
        #       status :not_found
        #       {
        #         success: false,
        #         error: 'Insufficient balance',
        #       }
        #     else
        #       status :not_found
        #       {
        #         success: false,
        #         error: 'Route wallet not present',
        #       }
        #     end
        #   else
        #     status :unprocessable_entity
        #     {
        #       success: false,
        #       error: 'Invalid partner pin',
        #     }
        #   end
        # rescue => error
        #   error! respond_with_json("Unable to do Wallet payment due to #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        # end

        desc 'Show order details.'
        route_param :id do
          get 'order/details' do
            customer_orders = @current_partner.customer_orders.find(params[:id])
            if @locale == :bn
              present customer_orders, with: ShopothPartner::V1::Entities::BnOrderDetails
            else
              present customer_orders, with: ShopothPartner::V1::Entities::OrderDetails
            end
          rescue StandardError => error
            Rails.logger.info "#{__FILE__} \nUnable to fetch customer order details due to: #{error.message}"
            error!(respond_with_json(I18n.t('Partner.errors.messages.order_details'), HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        end

        desc 'Partner: Deliver Order to Customer.'
        params do
          requires :order_id, type: Integer, allow_blank: false
          requires :customer_pin, type: String, allow_blank: false
        end
        post 'deliver_to_customer' do
          pin = params[:customer_pin]
          order = @current_partner.customer_orders.find_by(id: params[:order_id])
          warehouse = @current_partner.route.warehouse
          unless order && warehouse == order.warehouse
            Rails.logger.info 'No order found.'
            error!(respond_with_json(I18n.t('Partner.errors.messages.order_not_found'),
                                     HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          if order.status.delivered_to_partner?
            if pin == order.pin
              ActiveRecord::Base.transaction do
                update_warehouse_variant_in_partner_quantity(order)

                update_payment(order)
                update_order(order)
                create_partner_margin(@current_partner, order)
                DistributorMargin.create_commission(order)
              end
              # if order.organic?
              #   @current_partner.wallet.update(currency_amount: (@current_partner.wallet.currency_amount + PARCEL_HOLDING_FEE))
              #   order.update!(holding_fee: PARCEL_HOLDING_FEE)
              # end
              app_notification = AppNotification.customer_payment_notification(order)
              attributes = @locale == :bn ? get_hash(app_notification[:bn_title], app_notification[:bn_message]) : get_hash(app_notification[:title], app_notification[:message])
              PushNotification::CreateAppNotificationsPartner.call(
                app_user: @current_partner,
                title: app_notification[:title],
                bn_title: app_notification[:bn_title],
                message: app_notification[:message],
                bn_message: app_notification[:bn_message],
                attributes: attributes,
              )

              app_notification = AppNotification.order_delivered_to_customer(order)
              attributes = @locale == :bn ? get_hash(app_notification[:bn_title], app_notification[:bn_message]) : get_hash(app_notification[:title], app_notification[:message])
              PushNotification::CreateAppNotificationsPartner.call(
                app_user: @current_partner,
                title: app_notification[:title],
                bn_title: app_notification[:bn_title],
                message: app_notification[:message],
                bn_message: app_notification[:bn_message],
                attributes: attributes,
              )

              status :ok
              respond_with_json(I18n.t('Partner.success.messages.delivery_successful'), HTTP_CODE[:OK])
            else
              Rails.logger.info 'Wrong Pin provided.'
              error!(respond_with_json(I18n.t('Partner.errors.messages.wrong_pin'),
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
          else
            Rails.logger.info 'You are not allowed to delivered this order.'
            respond_with_json(I18n.t('Partner.errors.messages.deliver_to_customer'), HTTP_CODE[:NOT_FOUND])
          end
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to deliver order to customer due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.deliver_to_customer_failed'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Partner: Scan Invoice/Collect order.'
        params do
          requires :invoice_id, type: String
          optional :customer_id, type: String
          optional :order_id, type: String
        end

        put 'collect_order' do
          customer_order = @current_partner.customer_orders.find(params[:invoice_id].to_i)
          if customer_order.present? && customer_order.status&.order_type == 'in_transit'
            ActiveRecord::Base.transaction do
              if customer_order.b2b?
                customer_order.update(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]),
                                      pay_status: :customer_paid,
                                      completed_at: Time.now,
                                      changed_by: @current_partner)
                create_partner_margin(@current_partner, customer_order)
                DistributorMargin.create_commission(customer_order)

                app_notification = AppNotification.order_delivered_to_customer(customer_order)
                attributes = @locale == :bn ? get_hash(app_notification[:bn_title], app_notification[:bn_message]) : get_hash(app_notification[:title], app_notification[:message])
                PushNotification::CreateAppNotificationsPartner.call(
                  app_user: @current_partner,
                  title: app_notification[:title],
                  bn_title: app_notification[:bn_title],
                  message: app_notification[:message],
                  bn_message: app_notification[:bn_message],
                  attributes: attributes,
                )
              else
                customer_order.update(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:delivered_to_partner]),
                                      changed_by: @current_partner)
              end
              update_warehouse_variant_quantity(customer_order)
            end
            send_message(customer_order) unless customer_order.b2b?
            status :ok
            {
              success: true,
              message: I18n.t('Partner.success.messages.collect_order_success'),
            }
          else
            status :not_found
            {
              success: false,
              message: I18n.t('Partner.errors.messages.collect_order_failed'),
            }
          end
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to collect_order due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.collect_order_failed'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc "Partner's product search."
        params do
          requires :search_key, type: String
        end
        get 'product_search' do
          warehouse = @current_partner&.route&.warehouse
          products = select_products(warehouse, params[:search_key])
          ShopothPartner::V1::Entities::PartnerProducts.represent(
            products, warehouse: warehouse, language: request.headers['Language-Type']
          )
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to fetch products with title: #{params[:search_key]} due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.product_fetch_failed'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Partner list for a retailer assistant'
        route_setting :authentication, type: RetailerAssistant
        get :list do
          partners = @current_retailer.warehouse.partners.active.reorder('LOWER(name)')
          present partners, with: ShopothPartner::V1::Entities::PartnerList
        rescue StandardError => error
          error!(respond_with_json("Unable to fetch partners due to: #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Margin received by partner.'
        params do
          optional :month, type: Integer
          optional :year, type: Integer
        end
        post 'receive_margin' do
          month = params[:month] || Date.today.month
          year = params[:year] || Date.today.year
          existing_payment =
            AggregatedPayment.partner_margin.where(month: month,
                                                   year: year,
                                                   received_by: @current_partner)
          if existing_payment.present?
            error!(respond_with_json(I18n.t('Partner.errors.messages.payment_exist_error'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          sr_payment = AggregatedPayment.sr_margin.where(
            month: month, year: year, received_by: @current_partner.route,
          )
          unless sr_payment.present? && sr_payment.first&.payment&.successful?
            error!(respond_with_json(I18n.t('Partner.errors.messages.profit_sr_collect_error'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          ActiveRecord::Base.transaction do
            aggregated_payment =
              AggregatedPayment.partner_margin.create!(month: month,
                                                       year: year,
                                                       partner_schedule: @current_partner.schedule,
                                                       received_by: @current_partner)

            start_date = if params[:year].present? && params[:month].present?
                           DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
                         else
                           DateTime.now.beginning_of_month
                         end

            end_date = if params[:year].present? && params[:month].present?
                         DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
                       else
                         DateTime.now.end_of_month
                       end
            completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
            partial_return_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
            customer_orders = @current_partner.customer_orders.where(status: [completed_status, partial_return_status], completed_at: start_date..end_date)

            total_amount = @current_partner.create_aggregated_partner_payment(aggregated_payment, customer_orders)

            if total_amount.positive?
              Payment.create!(aggregated_payment: aggregated_payment,
                              currency_amount: total_amount,
                              currency_type: 'BDT',
                              status: :successful,
                              form_of_payment: :cash,
                              paymentable: @current_partner.route,
                              receiver: @current_partner)
              {
                message: I18n.t('Partner.success.messages.profit_collected_successfully'),
                status_code: HTTP_CODE[:OK],
              }
            else
              aggregated_payment.destroy
              status :unprocessable_entity
              respond_with_json(I18n.t('Partner.errors.messages.payment_exist_error'),
                                HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to receive profit margin due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.margin_received_failed'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Add bKash number to partner profile.'
        params do
          requires :bkash_number, type: String
        end
        put :add_bkash_number do
          if @current_partner&.bkash_number.present?
            error!(respond_with_json(I18n.t('Partner.errors.messages.bkash_already_taken'), HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:OK])
          end
          @current_partner.update!(bkash_number: params[:bkash_number])
          success_response_with_json(I18n.t('Partner.success.messages.add_bkash_number_successfully'), HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to add bKash number due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.add_bkash_number_error'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
