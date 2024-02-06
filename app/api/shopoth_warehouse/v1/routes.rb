module ShopothWarehouse
  module V1
    class Routes < ShopothWarehouse::Base
      helpers do
        def deleted_response(success_status: false, status: :unprocessable_entity, message:)
          status status
          {
            success: success_status,
            message: message,
            status_code: status,
          }
        end

        def filter_payments_by_today(payments)
          payments.select do |payment|
            format_time(payment.created_at) == format_time(Time.now)
          end
        end

        def format_time(date)
          date.strftime('%d/%m/%y')
        end

        def failed_qc_create(return_order, warehouse, failed_reasons)
          if return_order.unpacked?
            return_order.failed_qcs.create!(variant_id: return_order.shopoth_line_item.variant_id,
                                            quantity: 1, warehouse: warehouse, failed_reasons: failed_reasons,
                                            qc_failed_type: 'quality_failed')
            return_order.update_inventory_and_stock_changes('return_qc_failed_quantity', 'return_qc_pending_quantity')
          else
            return_order.customer_order.shopoth_line_items.each do |line_item|
              return_order.failed_qcs.create!(
                variant_id: line_item.variant_id, quantity: line_item.quantity,
                warehouse: warehouse, failed_reasons: failed_reasons,
                qc_failed_type: 'quality_failed', customer_order_id: return_order.customer_order.id
              )
            end
            return_order.update_inventory_and_stock_changes('return_qc_failed_quantity', 'return_qc_pending_quantity')
          end
        end
      end

      resource :routes do
        desc 'Get Route Wallet Balance.'
        route_setting :authentication, type: RouteDevice
        get '/wallet_balance' do
          paid_by_partners = 0
          staff = @current_route_device.route.warehouse.staffs.first
          # payments = Payment.where(status: 'successful',
          #                          paymentable: route,
          #                          receiver_id: staff.id,
          #                          receiver_type: staff.class.to_s)
          # today_payments = filter_payments_by_today(payments)
          # amount = today_payments.map(&:currency_amount).sum.to_f
          paid_to_dh = @current_route_device.route.customer_orders.joins(:payments).where(
            "payments.paymentable_type = 'Route' AND payments.paymentable_id = ? AND payments.receiver_type = 'Staff' AND payments.receiver_id = ?", @current_route_device.route.id, staff.id
          ).sum('payments.currency_amount')

          customer_orders = @current_route_device.route.customer_orders.joins(:payments).where(
            "payments.paymentable_type = 'Partner' AND payments.receiver_type = 'Route'",
          )
          customer_orders.each do |order|
            if order.payments.find_by(receiver_type: 'Staff').nil?
              paid_by_partners += order.payments.find_by(paymentable_type: 'Partner', receiver_type: 'Route', receiver_id: @current_route_device.route.id)&.currency_amount || 0
            end
          end
          {
            id: @current_route_device.route.id,
            cash_amount: paid_by_partners,
            paid_to_dh: paid_to_dh,
          }
        rescue StandardError => error
          Rails.logger.info "Balance show error: #{error.message}"
          error!(respond_with_json("Failed! Reason: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Wallet balance of a specific route.'
        route_param :id do
          get '/route_wallet' do
            route_wallet = @current_staff.warehouse.routes.find(params[:id])
            if route_wallet.present?
              present route_wallet, with: ShopothWarehouse::V1::Entities::RouteBalances
            else
              error!(respond_with_json("Couldn't find routes with id: #{params[:id]}", HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
          rescue
            error!(respond_with_json('Failed: You have given wrong rider ID.',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Get Route Phone Number.'
        route_setting :authentication, type: RouteDevice
        get '/phone' do
          route_phone = @current_route_device.route
          present route_phone, with: ShopothWarehouse::V1::Entities::RoutePhones
        rescue => error
          error! respond_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # CREATE ************************************************
        desc 'Create a new Route.'
        params do
          requires :route, type: Hash do
            requires :title, type: String
            requires :distributor_id, type: Integer
            requires :bn_title, type: String
            requires :phone, type: String
            optional :sr_point, type: String
            optional :sr_name, type: String
          end
        end

        post do
          if check_wh_warehouse
            error!(respond_with_json('You are not allowed to create any sales representative',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          params[:route].merge!(created_by_id: @current_staff.id)
          Route.create_instance(@current_staff.warehouse, params)
          respond_with_json('Successfully created', HTTP_CODE[:CREATED])
        rescue StandardError => error
          error!(respond_with_json("Unable to create route due to: #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Receive customer order from SR.'
        put '/receive_order/:id' do
          customer_order = CustomerOrder.find(params[:id])
          if customer_order.present? && customer_order.partner&.route&.warehouse == @current_staff.warehouse
            ActiveRecord::Base.transaction do
              status = customer_order.status.in_transit_cancelled? ? OrderStatus.getOrderStatus(OrderStatus.order_types[:packed_cancelled]) : OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment])
              if customer_order.status.in_transit_partner_switch? || customer_order.status.in_transit_delivery_switch?
                customer_order.update!(
                  partner_id: customer_order.next_shipping_type == CustomerOrder.shipping_types[:pick_up_point] ? customer_order.next_partner_id : nil,
                  shipping_type: customer_order.next_shipping_type,
                )
              end
              update_stock(customer_order, @current_warehouse.id)
              customer_order.update!(order_status_id: status.id, changed_by: @current_staff)
            end
            respond_with_json('Customer Order Received.', HTTP_CODE[:OK])
          else
            error!(respond_with_json('Customer Order not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to receive customer order due to: #{error.message}"
          error!(respond_with_json('Unable to receive customer order.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Update a specific route.'
        route_param :id do
          put do
            if check_wh_warehouse
              error!(respond_with_json('You are not allowed to edit any sales representative',
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            route = Route.find(params[:id])
            if params[:route][:distributor_id].present? && route.distributor_id != params[:route][:distributor_id] && route.partners.present?
              error!(respond_with_json("Distributor can't be changed because route has assigned partners.",
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end

            route.update!(params[:route])
            present route, with: ShopothWarehouse::V1::Entities::Routes
          rescue => error
            error!(respond_with_json("Unable to update route due to #{error.message}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # List ***********
        desc 'Get all Routes for export.'
        get '/export' do
          routes = check_wh_warehouse ? Route.all : @current_staff.warehouse.routes
          present routes.order(created_at: :desc), with: ShopothWarehouse::V1::Entities::Routes
        end

        # List ***********
        desc 'Get all Partners for Route list to export.'
        get '/partner_export' do
          routes = check_wh_warehouse ? Route.all : @current_staff.warehouse.routes
          routes = params[:title].present? ? routes.where('LOWER(title) LIKE ?', "%#{params[:title].downcase}%") : routes
          routes = params[:distributor_id].present? ? routes.where(distributor_id: params[:distributor_id]) : routes
          partners = []
          routes.select do |route|
            partners += route.partners.map do |partner|
              {
                sr_name: route.sr_name,
                partner_name: partner.name,
                partner_phone: partner.phone,
              }
            end
          end
          present routes.order(created_at: :desc), with: ShopothWarehouse::V1::Entities::Routes
        end

        desc 'Route list.'
        get do
          routes = check_dh_warehouse ? @current_staff.warehouse.routes : Route.all
          present routes.order(created_at: :desc), with: ShopothWarehouse::V1::Entities::Routes
        end

        desc 'Get collection details of reconciliation for routes.'
        params do
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
        end

        get ':id/cash_collected_summary' do
          route = @current_staff.warehouse.routes.find(params[:id])
          unless route
            error!(respond_with_json('Unable to find route.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a  range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time

          route_return_orders = route.return_customer_orders.joins(:return_status_changes).where(
            return_status_changes: { status: 'in_transit', created_at: date_range },
          )

          dh_return_orders = route_return_orders.select { |order| order.return_status_changes.find_by(status: :qc_pending).present? }

          route_customer_orders = route.customer_orders.joins(:payments).where(
            payments: { paymentable_type: 'Partner', receiver_type: 'Route', created_at: date_range },
          )

          dh_customer_orders_amount = route_customer_orders.sum do |order|
            order.payments.where("payments.paymentable_type = 'Route' AND payments.receiver_type = 'Staff'").sum(&:currency_amount)
          end

          routes_order_count(route_customer_orders.sum(:currency_amount), dh_customer_orders_amount,
                             route_return_orders, dh_return_orders)
        rescue StandardError => error
          error!(respond_with_json("Unable to find route's Information due to #{error.message}.",
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Get date_range filtered orders of routes.'
        params do
          use :pagination, per_page: 50
        end
        get ':id/cash_collected_orders' do
          route = @current_staff.warehouse.routes.find(params[:id])
          unless route
            error!(respond_with_json('Unable to find route.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a  range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time
          customer_orders = route.customer_orders.joins(:payments).where("payments.paymentable_type = 'Partner'
            AND payments.receiver_type = 'Route'").where(payments: { created_at: date_range }).includes(:payments)
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(customer_orders.order(created_at: :desc))),
                  with: ShopothWarehouse::V1::Entities::ReconciliationOrderDetailsByRoutes
        rescue StandardError => error
          error!(respond_with_json("Unable to find route's customer order due to #{error.message}",
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Export date_range filtered orders of routes.'
        params do
          use :pagination, per_page: 50
        end
        get ':id/cash_collected_orders_export' do
          route = @current_staff.warehouse.routes.find(params[:id])
          unless route
            error!(respond_with_json('Unable to find route.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a  range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time
          customer_orders = route.customer_orders.joins(:payments).where("payments.paymentable_type = 'Partner'
            AND payments.receiver_type = 'Route'").where(payments: { created_at: date_range }).includes(:payments)
          present customer_orders.order(created_at: :desc), with: ShopothWarehouse::V1::Entities::ReconciliationOrderDetailsByRoutes
        rescue StandardError => error
          error!(respond_with_json("Unable to find route's customer order due to #{error.message}",
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Get all return_customer_orders of a specific route.'
        params do
          use :pagination, per_page: 50
        end
        get ':id/return_requests' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a  range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          warehouse = @current_staff.warehouse
          route = warehouse.routes.find(params[:id])
          return_requests = route.return_customer_orders.joins(:return_status_changes).where(
            return_status_changes: { created_at: start_date_time..end_date_time, status: 'in_transit' },
          )
          # TODO: Need to Optimize Query
          ShopothWarehouse::V1::Entities::ReturnRequestWithLocations.represent(
            paginate(Kaminari.paginate_array(return_requests)), warehouse: warehouse
          )
        end

        desc 'Get all Returned customer_orders of a specific route.'
        params do
          use :pagination, per_page: 50
        end
        get ':id/return_orders' do
          route = @current_staff.warehouse.routes.find(params[:id])
          order_status = %w(in_transit_partner_switch in_transit_cancelled in_transit_reschedule in_transit_delivery_switch)
          customer_orders = route.customer_orders.map do |customer_order|
            customer_order if order_status.include?(customer_order.status.order_type.to_s)
          end.flatten.compact
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(customer_orders)),
                  with: ShopothWarehouse::V1::Entities::CustomerOrderList
        end

        # Route List with Pagination ***********
        desc 'Route list with pagination.'
        params do
          use :pagination, per_page: 50
        end

        get '/paginate' do
          routes = check_dh_warehouse ? @current_staff.warehouse.routes : Route.all
          routes = params[:distributor_id].present? ? routes.where(distributor_id: params[:distributor_id]) : routes
          routes = params[:title].present? ? routes.where('LOWER(title) LIKE ?', "%#{params[:title].downcase}%") : routes
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(routes.order(created_at: :desc))), with: ShopothWarehouse::V1::Entities::Routes
        end

        desc 'Return a specific route.'
        route_param :id do
          get do
            route = Route.find(params[:id])
            present route, with: ShopothWarehouse::V1::Entities::RouteDetails
          rescue => ex
            error! respond_with_json("Unable to fetch route due to: #{ex.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end
        end

        desc 'Delete a specific route.'
        route_param :id do
          delete do
            if check_wh_warehouse
              error!(respond_with_json('Not permitted to delete', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end
            route = @current_staff.warehouse.routes.find_by(id: params[:id])
            unless route.present?
              error!(respond_with_json('Route not found', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            associate_partners = route.partners
            if associate_partners.present?
              error!(respond_with_json('This route is connected to partners', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end
            respond_with_json('Successfully deleted', HTTP_CODE[:OK]) if route.destroy!
          rescue => error
            Rails.logger.info "Unable to delete #{error.message}"
            error!(failure_response_with_json('Unable to delete route',
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end
        end

        # Collect Payment *********
        desc 'Collect Payment from Partner.'
        route_setting :authentication, type: RouteDevice
        params do
          requires :order_id, type: Integer
        end

        post 'collect_payment' do
          route = @current_route_device.route
          customer_order = route.customer_orders.find(params[:order_id])
          unless (customer_order.status.completed? || customer_order.status.returned_from_customer? || customer_order.status.partially_returned?) && customer_order.customer_paid?
            error!(respond_with_json("Can't collect money for this customer order",
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end

          partner_paid = customer_order.payments.successful.where(paymentable: customer_order.partner, receiver_type: 'Route').sum(:currency_amount)
          partner_received = customer_order.payments.successful.where(paymentable_type: 'User', receiver_type: 'Partner').sum(:currency_amount)
          payable_amount = partner_received - partner_paid
          remaining_amount = customer_order.b2b? ? customer_order.b2b_order_value : payable_amount

          if remaining_amount.positive? || customer_order.payments.find_by(paymentable: customer_order.partner, receiver_type: 'Route').nil?
            customer_order.partner.payments.create!(currency_amount: remaining_amount,
                                                    currency_type: 'BDT',
                                                    status: :successful,
                                                    customer_order_id: params[:order_id],
                                                    receiver_id: route.id,
                                                    receiver_type: route.class.to_s)
            route.update(cash_amount: route.cash_amount + remaining_amount)

            app_notification = AppNotification.money_transaction_notification(customer_order, remaining_amount, 'cash')
            PushNotification::CreateAppNotifications.call(
              app_user: route,
              title: app_notification[:title],
              bn_title: app_notification[:bn_title],
              message: app_notification[:message],
              bn_message: app_notification[:bn_message])
          end
          status :ok
          customer_order.b2b? ? customer_order.update(pay_status: :partner_paid, is_customer_paid: true) : customer_order.update(pay_status: :partner_paid)
          { status: true, message: 'Successfully collected payment from partner' }
        rescue => ex
          error!("Unable to collect payment from partner due to #{ex.message}")
        end

        desc 'Collect Payment of all orders for a specific Route.'
        params do
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
        end
        post ':id/cash_receive' do
          route = @current_staff.warehouse.routes.find(params[:id])
          unless route
            error!(respond_with_json('Unable to find route.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a  range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time
          customer_orders = route.customer_orders.joins(:payments).where("payments.paymentable_type = 'Partner'
            AND payments.receiver_type = 'Route'").where(payments: { created_at: date_range })
          customer_orders = customer_orders.select do |order|
            order.payments.find_by(receiver_type: 'Staff').nil?
          end

          if customer_orders
            total_payment = 0
            customer_orders.each do |order|
              total_amount = order.payments.where("payments.paymentable_type = 'Partner' AND payments.receiver_type = 'Route'").sum(&:currency_amount)
              route.payments.create!(currency_amount: total_amount,
                                     currency_type: 'BDT',
                                     status: :successful,
                                     form_of_payment: :cash,
                                     customer_order_id: order.id,
                                     receiver_id: @current_staff.id,
                                     receiver_type: @current_staff.class.to_s)
              total_payment += total_amount
              order.update(pay_status: :dh_received)
            end

            respond_with_json('Customer Orders payments received by Fulfillment Center.', HTTP_CODE[:OK])
          else
            error!(respond_with_json('Unable to find Customer Orders.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        rescue StandardError => error
          Rails.logger.info "Error! Reason #{error.message}"
          error!(respond_with_json("Unable to find route due to #{error.message}.", HTTP_CODE[:NOT_FOUND]),
                 HTTP_CODE[:NOT_FOUND])
        end

        desc "Quality control for Route's Return_customer_orders."
        params do
          requires :return_order_id, type: Integer
          requires :failed_reasons, type: Array
        end

        post ':id/return_qc' do
          warehouse = @current_staff.warehouse
          route = warehouse.routes.find(params[:id])
          return_order = route.return_customer_orders.find(params[:return_order_id])
          failed_reasons = params[:failed_reasons]

          if return_order.qc_pending? && failed_reasons.count.positive?
            ActiveRecord::Base.transaction do
              failed_qc_create(return_order, warehouse, failed_reasons)
              return_order.update!(return_status: :completed, qc_status: :failed, changeable: @current_staff)
            end
            respond_with_json('Qc failed.', HTTP_CODE[:OK])
          elsif return_order.qc_pending?
            ActiveRecord::Base.transaction do
              return_order.update!(return_status: :relocation_pending, qc_status: :passed, changeable: @current_staff)
              return_order.update_inventory_and_stock_changes('return_location_pending_quantity', 'return_qc_pending_quantity')
            end
            respond_with_json('Qc passed.', HTTP_CODE[:OK])
          else
            error!(respond_with_json('Unable to find Return Customer Order', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        rescue StandardError => error
          error!(respond_with_json("Unable to complete QC due to #{error.message}.",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # Extent 2 days *********
        desc 'Extend Payment for Partner'
        route_setting :authentication, type: RouteDevice
        params do
          requires :order_id, type: Integer
        end

        post 'extend_payment' do
          customer_order = CustomerOrder.find(params[:order_id])
          if customer_order.update!(pay_status: :extended)
            app_notification = AppNotification.payment_exceeded(customer_order)
            PushNotification::CreateAppNotifications.call(
              app_user: @current_route_device.route,
              title: app_notification[:title],
              bn_title: app_notification[:bn_title],
              message: app_notification[:message],
              bn_message: app_notification[:bn_message])

            status :ok
            { status: true, message: 'Payment Extended' }
          else
            status :unprocessable_entity
            { status: false, message: 'Payment Extension failed' }
          end
        rescue => ex
          error!("Unable to extend payment for partner due to #{ex.message}")
        end
      end
    end
  end
end
