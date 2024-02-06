# frozen_string_literal: true

module ShopothRider
  module V1
    class Riders < ShopothRider::Base
      DELIVERY_STATUS = %w(ready_to_shipment in_transit)
      TODAY_STATUS = %w(completed cancelled)
      helpers do
        def format_time(time)
          time&.strftime("%m/%d/%Y")
        end

        def update_warehouse_variant_quantity(customer_order)
          items = customer_order.shopoth_line_items
          wh_variants = WarehouseVariant.group_by_wh_variant(items, @current_rider.warehouse.id)
          wh_variants.each do |wh_v|
            if (wh_v['wv_id'].ready_to_ship_quantity - wh_v['qty']).negative?
              Rails.logger.error "\nPacked_quantity is being negative for warehouse_variant_id: #{wh_v['wv_id'].id}.
              Action: SR -> Scan Packed customer order: #{wh_v['stock_changeable'].id}\n"
            end
            wh_v['wv_id'].update!(ready_to_ship_quantity: wh_v['wv_id'].ready_to_ship_quantity - wh_v['qty'],
                                  in_transit_quantity: wh_v['wv_id'].in_transit_quantity + wh_v['qty'])
            wh_v['wv_id'].save_stock_change('customer_order_in_transit', wh_v['qty'], wh_v['stock_changeable'],
                                            'ready_to_ship_quantity_change', 'in_transit_quantity_change')
          end
        end

        def update_warehouse_variant_intransit_quantity(customer_order)
          items = customer_order.shopoth_line_items
          wh_variants = WarehouseVariant.group_by_wh_variant(items, @current_rider.warehouse.id)
          wh_variants.each do |wh_v|
            if (wh_v['wv_id'].in_transit_quantity - wh_v['qty']).negative?
              Rails.logger.error "\nIn_transit_quantity is being negative for warehouse_variant_id: #{wh_v['wv_id'].id}.
              Rider -> Handover customer order: #{wh_v['stock_changeable'].id}\n"
            end
            wh_v['wv_id'].update!(in_transit_quantity: wh_v['wv_id'].in_transit_quantity - wh_v['qty'])
            wh_v['wv_id'].save_stock_change('customer_order_completed', wh_v['qty'], wh_v['stock_changeable'],
                                            'in_transit_quantity_change', nil)
          end
        end

        def send_message(customer_order)
          I18n.locale = :bn
          message = I18n.t('rider_in_transit', customer_name: customer_order.name,
                                               order_id: customer_order.backend_id,
                                               total_price: customer_order.total_price.to_i,
                                               rider_name: @current_rider.name,
                                               pin: customer_order.pin)
          SmsManagement::SendMessage.call(phone: customer_order.phone, message: message)
        end
      end
      resource '/' do
        desc 'Log a shopoth_rider'
        route_setting :authentication, optional: true
        post '/login' do
          params do
            requires :phone, type: String
            requires :password, type: String
          end
          rider = Rider.find_by(phone: params[:phone])
          if rider&.password == params[:password]
            rider.create_app_config() if rider.app_config.nil?
            rider.app_config.update!(fcm_token: request.headers['Fcm-Token']) if request.headers['Fcm-Token'].present?
            status :ok
            {
              auth_token: JsonWebToken.login_token_encode(rider),
            }
          else
            status :unprocessable_entity
            {
              error: 'Invalid phone or password',
            }
          end
        end

        desc 'Get rider app version config.'
        route_setting :authentication, optional: true
        get '/app_config' do
          Configuration.return_app_version_config('rider_app')
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nRider app version config fetch failed due to: #{error.message}"
          error!(respond_with_json('Rider app version config fetch failed.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Return Home_delivery_list.'
        get '/home_delivery' do
          customer_orders = @current_rider.customer_orders.where(shipping_type: :home_delivery)
          orders = customer_orders.select do |order|
            DELIVERY_STATUS.include?(order.status.order_type.to_s) ||
              (TODAY_STATUS.include?(order.status.order_type) && format_time(order.completed_at) == format_time(Time.now))
          end
          on_hold_orders = customer_orders.select do |order|
            order.status.order_type == 'on_hold'
          end
          present orders.concat(on_hold_orders).sort_by(&:id), with: ShopothRider::V1::Entities::RidersHomeDelivery
        rescue => error
          error! respond_with_json(error, HTTP_CODE[:NOT_FOUND])
        end

        desc 'Return Express_delivery_list.'
        get '/express_delivery' do
          customer_orders = @current_rider.customer_orders.where(shipping_type: :express_delivery)
          orders = customer_orders.select do |order|
            DELIVERY_STATUS.include?(order.status.order_type.to_s) ||
              (TODAY_STATUS.include?(order.status.order_type) && format_time(order.completed_at) == format_time(Time.now))
          end
          present orders.sort_by(&:id), with: ShopothRider::V1::Entities::RidersHomeDelivery
        rescue => error
          error! respond_with_json(error, HTTP_CODE[:NOT_FOUND])
        end

        desc 'Return History.'
        get '/history/return' do
          status :ok
          []
        rescue => error
          error! respond_with_json(error, HTTP_CODE[:NOT_FOUND])
        end

        desc 'Rider Scan packed customer_order invoice.'
        params do
          requires :invoice_id, type: String
          optional :order_id, type: String
        end
        post 'scan_product' do
          customer_order = @current_rider.customer_orders.find(params[:invoice_id].to_i)
          if params[:order_id].present? && customer_order.id != params[:order_id].to_i
            error!(respond_with_json('Wrong invoice scanned.',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          unless customer_order.status.ready_to_shipment?
            error!(respond_with_json("This order can't be moved to in_transit.",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          ActiveRecord::Base.transaction do
            customer_order.update!(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit]),
                                   changed_by: @current_rider)
            update_warehouse_variant_quantity(customer_order)
          end

          send_message(customer_order)
          status :ok
          ShopothRider::V1::Entities::RidersHomeDelivery.represent(customer_order)
        rescue StandardError => error
          Rails.logger.info "rider app: customer order in transit failed- #{error.message}"
          error!(respond_with_json('Invalid order scanned under this rider.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Handover order to customer.'
        params do
          requires :order_id, type: Integer
          requires :pin, type: String
        end
        post 'product_handover' do
          customer_order = @current_rider.customer_orders.find(params[:order_id])
          if customer_order.pin == params[:pin] && customer_order.status.in_transit?
            ActiveRecord::Base.transaction do
              total_amount = 0
              unless customer_order.is_customer_paid?
                paid_amount = customer_order.payments&.where(status: :successful, paymentable: customer_order.customer)&.sum(:currency_amount)
                total_amount = customer_order.total_price - paid_amount
              end

              if customer_order.status != OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
                customer_order.update!(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]),
                                       is_customer_paid: true,
                                       pay_status: :customer_paid,
                                       changed_by: @current_rider,
                                       completed_at: Time.now)
                update_warehouse_variant_intransit_quantity(customer_order)
              end

              if total_amount.positive? || customer_order.payments.find_by(receiver_type: 'Rider').nil?
                customer_order.payments.create!(currency_amount: total_amount,
                                                currency_type: 'BDT',
                                                status: :successful,
                                                paymentable: customer_order.customer,
                                                receiver_id: @current_rider.id,
                                                receiver_type: @current_rider.class.to_s)
              end
              DistributorMargin.create_commission(customer_order)
            end

            app_notification = AppNotification.customer_payment_notification(customer_order)
            PushNotification::CreateAppNotifications.call(
              app_user: @current_rider,
              title: app_notification[:title],
              bn_title: app_notification[:bn_title],
              message: app_notification[:message],
              bn_message: app_notification[:bn_message])

            app_notification = AppNotification.order_delivered_to_customer(customer_order)
            PushNotification::CreateAppNotifications.call(
              app_user: @current_rider,
              title: app_notification[:title],
              bn_title: app_notification[:bn_title],
              message: app_notification[:message],
              bn_message: app_notification[:bn_message])

            status :ok
            {
              success: true,
              order_id: customer_order.id,
              amount_paid: customer_order.payments.find_by(paymentable_type: 'User',
                                                           receiver_type: 'Rider').currency_amount,
              pay_type: customer_order.pay_type,
            }
          else
            status :not_acceptable
            respond_with_json('Incorrect pin provided or wrong invoice', HTTP_CODE[:NOT_ACCEPTABLE])
          end
        rescue StandardError => error
          Rails.logger.info "rider app-deliver failed #{error.message}"
          error!(respond_with_json('Wrong invoice scanned', HTTP_CODE[:NOT_ACCEPTABLE]),
                 HTTP_CODE[:NOT_ACCEPTABLE])
        end

        desc 'Order on hold'
        params do
          requires :order_id, type: Integer
        end
        post 'put_order_on_hold' do
          customer_order = CustomerOrder.find(params[:order_id])

          if customer_order.present? && customer_order.rider == @current_rider && customer_order.status == OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit])
            customer_order.update(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:on_hold]),
                                  changed_by: @current_rider)
            status :ok
            {
              success: true,
              message: 'Status changed from in-transit to on-hold',
            }
          else
            status :not_acceptable
            respond_with_json('Status Not Updated', HTTP_CODE[:NOT_ACCEPTABLE])
          end
        end

        desc 'Reset on hold status'
        params do
          requires :order_id, type: Integer
        end
        post 'reset_on_hold_status' do
          customer_order = CustomerOrder.find(params[:order_id])

          if customer_order.present? && customer_order.rider == @current_rider && customer_order.status == OrderStatus.getOrderStatus(OrderStatus.order_types[:on_hold])
            customer_order.update(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit]),
                                  changed_by: @current_rider)
            status :ok
            {
              success: true,
              message: 'Status changed from on-hold to in-transit',
            }
          else
            status :not_acceptable
            respond_with_json('Status Not Updated', HTTP_CODE[:NOT_ACCEPTABLE])
          end
        end

        desc 'Report to Customer Care'
        params do
          requires :order_id, type: Integer
          requires :report_type, type: Integer
        end
        post 'report_customer_care' do
          report = @current_rider.customer_care_reports.new(customer_order_id: params[:order_id], report_type: params[:report_type])
          if report.save!
            status :ok
            { success: true, message: 'Reported' }
          else
            status :unprocessable_entity
            { error: 'Something Went wrong' }
          end
        end

        desc 'Rider Dashboard'
        get '/dashboard' do
          rider_orders = @current_rider.customer_orders
          return ::Utilities::RiderUtility.common_dashboard_hash unless rider_orders.present?

          count_hash_context = OrderManagement::RiderOrder.call(orders: rider_orders, rider: @current_rider)
          if count_hash_context.success?
            status :ok
            count_hash_context.count_hash
          end

        rescue => ex
          error! respond_with_json("Unable to generate dashboard due to: #{ex.message}",
                                   HTTP_CODE[:NOT_FOUND])
        end

        desc 'Rider Delivery History'
        get 'delivery_history' do
          customer_orders = @current_rider.customer_orders
          return [] unless customer_orders.present?

          delivery_history_context = OrderManagement::RiderDeliveryHistory.call(orders: customer_orders)
          if delivery_history_context.success?
            status :ok
            prepare_order_history(delivery_history_context.delivery_history)
          end

        rescue => ex
          error! respond_with_json("Unable to fetch delivery story due to #{ex.message}",
                                   HTTP_CODE[:NOT_FOUND])

        end

        desc 'Rider Payment History'
        get 'payment_history' do
          customer_orders = @current_rider.customer_orders
          return [] unless customer_orders.present?

          payment_history_context = OrderManagement::RiderPaymentHistory.call(orders: customer_orders)
          if payment_history_context.success?
            prepare_order_history(payment_history_context.payment_history)
          end

        rescue => ex
          error! respond_with_json("Unable to fetch payment history due to #{ex.message}",
                                   HTTP_CODE[:NOT_FOUND])
        end

        desc 'rider reports'
        get 'reports' do
          customer_orders = @current_rider.customer_orders
          error! respond_with_json('No data found', HTTP_CODE[:NOT_FOUND]) unless customer_orders.present?
          report_context = OrderManagement::GenerateRiderReport.call(orders: customer_orders)
          report_context.report_hash if report_context.success?
        rescue => ex
          error! respond_with_json("Unable to fetch report due to #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
