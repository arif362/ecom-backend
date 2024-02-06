# frozen_string_literal: true

module ShopothDistributor
  module V1
    class Routes < ShopothDistributor::Base
      resource '/routes' do
        desc 'Get all routes.'
        params do
          optional :title, type: String
          use :pagination, per_page: 50
        end
        get do
          routes = if params[:title].present?
                     @current_distributor.routes.where('LOWER(title) LIKE ?', "#{params[:title].downcase}%")
                   else
                     @current_distributor.routes
                   end

          response = ShopothDistributor::V1::Entities::Routes.represent(
            paginate(Kaminari.paginate_array(routes.sort_by { |r| r.title.strip.downcase })),
          )
          success_response_with_json('Successfully fetched routes.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch routes due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch routes.', HTTP_CODE[:UNPROCESSABLE_ENTITY], []),
                 HTTP_CODE[:OK])
        end

        desc 'Get reconcile routes on DH panel.'
        params do
          use :pagination, per_page: 50
          optional :title, type: String
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
          optional :skip_pagination, type: Boolean
        end
        get '/reconcile' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
          routes = params[:title].present? ? @current_distributor.routes.where('LOWER(title) LIKE ?', "%#{params[:title].downcase}%") : @current_distributor.routes
          routes = Route.filter_with_date_range(@current_distributor.customer_orders, routes, start_date_time..end_date_time)
          routes = if params[:skip_pagination]
                     routes
                   else
                     paginate(Kaminari.paginate_array(routes))
                   end

          response = ShopothWarehouse::V1::Entities::ReconciliationRoutes.represent(
            routes.sort_by { |r| r.title.strip.downcase },
          )
          success_response_with_json('Successfully fetched routes.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch routes due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch routes.', HTTP_CODE[:UNPROCESSABLE_ENTITY], []),
                 HTTP_CODE[:OK])
        end

        route_param :id do
          before do
            @route ||= @current_distributor.routes.find_by(id: params[:id])
            unless @route
              error!(failure_response_with_json('Unable to find route.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
          end

          desc 'Get a specific route details on DH panel.'
          get do
            success_response_with_json('Successfully fetched route details.', HTTP_CODE[:OK],
                                       ShopothWarehouse::V1::Entities::RouteDetails.represent(@route))
          rescue StandardError => error
            Rails.logger.error "\n\n#{__FILE__}Unable to fetch route details due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch route details.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc 'Get routes cash collection summary on Dh panel.'
          params do
            optional :start_date_time, type: DateTime
            optional :end_date_time, type: DateTime
          end
          get '/cash_collection_summary' do
            start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
            end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
            unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
              error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            date_range = start_date_time..end_date_time
            route_return_orders = @route.return_customer_orders.joins(:return_status_changes).where(
              return_status_changes: { status: 'in_transit', created_at: date_range },
            )
            dh_return_orders = route_return_orders.select { |order| order.return_status_changes.find_by(status: :delivered_to_dh).present? }
            route_customer_orders = @route.customer_orders.joins(:payments).where(
              payments: { paymentable_type: 'Partner', receiver_type: 'Route', created_at: date_range },
            )
            dh_customer_orders_amount = route_customer_orders.sum do |order|
              order.payments.where(paymentable_type: 'Route', receiver_type: 'Staff').sum(:currency_amount)
            end

            response = routes_order_count(route_customer_orders.sum(:currency_amount), dh_customer_orders_amount,
                                          route_return_orders, dh_return_orders, @route)
            success_response_with_json('Successfully fetched routes cash collection summary.',
                                       HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n\n#{__FILE__}Unable to fetch routes cash collection summary due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch routes cash collection summary.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc "Get route's cash collected orders on DH panel."
          params do
            use :pagination, per_page: 50
            optional :start_date_time, type: DateTime
            optional :end_date_time, type: DateTime
            optional :skip_pagination, type: Boolean
          end
          get '/cash_collected_orders' do
            start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
            end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
            unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
              error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            date_range = start_date_time..end_date_time
            customer_orders = @route.customer_orders.joins(:payments).where(
              payments: { paymentable_type: 'Partner', receiver_type: 'Route', created_at: date_range },
            ).includes(:payments)
            customer_orders = customer_orders.order(created_at: :desc)
            customer_orders = paginate(Kaminari.paginate_array(customer_orders)) unless params[:skip_pagination]

            response = ShopothWarehouse::V1::Entities::ReconciliationOrderDetailsByRoutes.represent(customer_orders)
            success_response_with_json("Successfully fetched route's cash collected orders.",
                                       HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n\n#{__FILE__}Unable to fetch route's cash collected orders due to: #{error.message}"
            error!(failure_response_with_json("Unable to fetch route's cash collected orders.",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc "Get route's return_customer_orders on DH panel."
          params do
            use :pagination, per_page: 50
            optional :start_date_time, type: DateTime
            optional :end_date_time, type: DateTime
          end
          get '/return_requests' do
            start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
            end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
            unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
              error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            date_range = start_date_time..end_date_time
            return_requests = @route.return_customer_orders.joins(:return_status_changes).where(
              return_status_changes: { created_at: date_range, status: 'in_transit' },
            )
            response = ShopothWarehouse::V1::Entities::ReturnRequestWithLocations.represent(
              paginate(Kaminari.paginate_array(return_requests)), warehouse: @current_distributor.warehouse
            )
            success_response_with_json("Successfully fetched route's return_customer_orders.",
                                       HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n\n#{__FILE__}Unable to fetch route's return_customer_orders due to: #{error.message}"
            error!(failure_response_with_json("Unable to fetch route's return_customer_orders.",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc "Get route's customer_orders that are returned on DH panel."
          params do
            use :pagination, per_page: 50
          end
          get '/returned_orders' do
            order_status = %w(in_transit_partner_switch in_transit_cancelled in_transit_reschedule in_transit_delivery_switch)
            customer_orders = @route.customer_orders.where(distributor: @current_distributor, order_status_id: OrderStatus.where(order_type: order_status).ids)
            response = ShopothWarehouse::V1::Entities::CustomerOrderList.represent(
              paginate(Kaminari.paginate_array(customer_orders)),
            )
            success_response_with_json("Successfully fetched route's customer_orders.", HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n\n#{__FILE__}Unable to fetch route's customer_orders due to: #{error.message}"
            error!(failure_response_with_json("Unable to fetch route's customer_orders.",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc "Get route details and it's partner margins on Dh panel."
          params do
            requires :month, type: Integer
            requires :year, type: Integer
            requires :partner_schedule, type: String
          end
          get '/partner_margins' do
            response = ShopothWarehouse::V1::Entities::RouteMargin.represent(
              @route, month: params[:month], year: params[:year], partner_schedule: params[:partner_schedule]
            )
            success_response_with_json('Successfully fetched partner margins.', HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch partner margins due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch partner margins.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end

          desc 'Collect payment of customer orders of routes on DH panel.'
          params do
            optional :start_date_time, type: DateTime
            optional :end_date_time, type: DateTime
          end
          post '/cash_receive' do
            start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
            end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
            unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
              error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            date_range = start_date_time..end_date_time
            customer_orders = @route.customer_orders.joins(:payments).where(
              payments: { created_at: date_range, paymentable_type: 'Partner', receiver_type: 'Route' },
            )
            customer_orders = customer_orders.select do |order|
              order.payments.find_by(receiver_type: 'Staff').nil?
            end

            unless customer_orders.present?
              error!(failure_response_with_json('Unable to find customer orders.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end

            total_payment = 0
            ActiveRecord::Base.transaction do
              customer_orders.each do |order|
                total_amount = order.payments.where(paymentable_type: 'Partner', receiver_type: 'Route').sum(:currency_amount)
                @route.payments.create!(currency_amount: total_amount,
                                        currency_type: 'BDT',
                                        status: :successful,
                                        form_of_payment: :cash,
                                        customer_order: order,
                                        receiver_id: @current_staff.id,
                                        receiver_type: @current_staff.class.to_s)
                total_payment += total_amount
                order.update!(pay_status: :dh_received)
              end

              success_response_with_json('Customer order payments received successfully.', HTTP_CODE[:OK])
            end
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to receive customer order payments due to: #{error.message}"
            error!(failure_response_with_json('Unable to receive customer order payments.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end

        desc 'Receive customer order from SR on DH panel.'
        put '/receive_order/:id' do
          customer_order = @current_distributor.customer_orders.find_by(id: params[:id])
          unless customer_order
            error!(failure_response_with_json('Customer order not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          route = customer_order.partner&.route
          unless route.warehouse == @current_distributor.warehouse && route.distributor == @current_distributor
            error!(failure_response_with_json("Customer order can't be received.", HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end

          order_receivable_statuses = %w(in_transit_partner_switch in_transit_delivery_switch in_transit_reschedule in_transit_cancelled)
          order_status = customer_order.status
          unless OrderStatus.fetch_statuses(order_receivable_statuses).include?(order_status)
            error!(failure_response_with_json("Customer order can't be received.", HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end

          partner_id = customer_order.partner_id
          shipping_type = customer_order.shipping_type
          ActiveRecord::Base.transaction do
            prev_status = order_status
            status = order_status.in_transit_cancelled? ? OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled_at_dh]) : OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment])
            if order_status.in_transit_partner_switch? || order_status.in_transit_delivery_switch?
              partner_id = customer_order.next_shipping_type == CustomerOrder.shipping_types[:pick_up_point] ? customer_order.next_partner_id : nil
              shipping_type = customer_order.next_shipping_type
            end
            update_stock(customer_order, @current_distributor.warehouse_id)
            customer_order.update!(status: status, changed_by: @current_staff, partner_id: partner_id,
                                   shipping_type: shipping_type)
            success_response_with_json('Customer order received successfully.', HTTP_CODE[:OK])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to receive customer order due to: #{error.message}"
          error!(failure_response_with_json('Unable to receive customer order.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
