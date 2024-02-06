# frozen_string_literal: true

module ShopothDistributor
  module V1
    class Riders < ShopothDistributor::Base
      resource '/riders' do
        desc 'Get all riders.'
        params do
          use :pagination, per_page: 50
        end
        get do
          response = ShopothWarehouse::V1::Entities::Riders.represent(
            paginate(Kaminari.paginate_array(@current_distributor.riders)),
          )
          success_response_with_json('Successfully fetched riders.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch riders due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch riders.', HTTP_CODE[:UNPROCESSABLE_ENTITY], []),
                 HTTP_CODE[:OK])
        end

        desc 'Get reconcile riders on DH panel.'
        params do
          use :pagination, per_page: 50
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
          optional :skip_pagination, type: Boolean
        end
        get '/reconcile' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
          riders = Rider.filter_with_date_range(@current_distributor.customer_orders, @current_distributor.riders, start_date_time, end_date_time)
          riders = if params[:skip_pagination]
                     riders
                   else
                     paginate(Kaminari.paginate_array(riders))
                   end

          response = ShopothWarehouse::V1::Entities::ReconciliationRiders.represent(riders)
          success_response_with_json('Successfully fetched riders.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch riders due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch riders.', HTTP_CODE[:UNPROCESSABLE_ENTITY], []),
                 HTTP_CODE[:OK])
        end

        route_param :id do
          before do
            @rider = @current_distributor.riders.find_by(id: params[:id])
            unless @rider
              error!(failure_response_with_json('Unable to find rider.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
          end

          desc 'Get a specific rider details for DH panel reconciliation.'
          get do
            success_response_with_json('Successfully fetched rider details.', HTTP_CODE[:OK],
                                       { name: @rider.name || '', phone: @rider.phone || '', email: @rider.email || '' })
          rescue StandardError => error
            Rails.logger.error "\n\n#{__FILE__}Unable to fetch rider details due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch rider details.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc 'Get riders cash collection summary for Dh.'
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
            rider_return_orders = @rider.return_customer_orders.joins(:return_status_changes).where(
              return_status_changes: { status: 'in_transit', created_at: date_range },
            )
            dh_return_orders = rider_return_orders.select { |order| order.return_status_changes.find_by(status: :delivered_to_dh).present? }
            rider_customer_orders = @rider.customer_orders.joins(:payments).where(
              payments: { paymentable_type: 'User', receiver_type: 'Rider', created_at: date_range },
            )
            dh_customer_orders_amount = rider_customer_orders.sum do |order|
              order.payments.where(paymentable_type: 'Rider', receiver_type: 'Staff').sum(:currency_amount)
            end

            response = riders_order_count(rider_customer_orders.sum(:currency_amount), dh_customer_orders_amount,
                                          rider_return_orders, dh_return_orders, @rider)
            success_response_with_json('Successfully fetched riders cash collection summary.',
                                       HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n\n#{__FILE__}Unable to fetch riders cash collection summary due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch riders cash collection summary.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc "Get rider's cash collected orders on DH panel."
          params do
            use :pagination, per_page: 50
            optional :start_date_time, type: DateTime
            optional :end_date_time, type: DateTime
          end
          get '/cash_collected_orders' do
            start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
            end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
            unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
              error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            date_range = start_date_time..end_date_time
            customer_orders = @rider.customer_orders.joins(:payments).where(
              payments: { paymentable_type: 'User', receiver_type: 'Rider', created_at: date_range },
            ).includes(:payments)
            response = ShopothWarehouse::V1::Entities::ReconciliationOrderDetailsByRiders.represent(
              paginate(Kaminari.paginate_array(customer_orders.order(created_at: :desc))),
            )
            success_response_with_json("Successfully fetched rider's cash collected orders.",
                                       HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n\n#{__FILE__}Unable to fetch rider's cash collected orders due to: #{error.message}"
            error!(failure_response_with_json("Unable to fetch rider's cash collected orders.",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc "Get rider's return_customer_orders on DH panel."
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
            return_requests = @rider.return_customer_orders.joins(:return_status_changes).where(
              return_status_changes: { created_at: date_range, status: 'in_transit' },
            )
            response = ShopothWarehouse::V1::Entities::ReturnRequestWithLocations.represent(
              paginate(Kaminari.paginate_array(return_requests)), warehouse: @current_distributor.warehouse
            )
            success_response_with_json("Successfully fetched rider's return_customer_orders.",
                                       HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n\n#{__FILE__}Unable to fetch rider's return_customer_orders due to: #{error.message}"
            error!(failure_response_with_json("Unable to fetch rider's return_customer_orders.",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc "Get rider's customer_orders that are returned on DH panel."
          params do
            use :pagination, per_page: 50
          end
          get '/returned_orders' do
            order_status = %w(in_transit_cancelled in_transit_reschedule in_transit_delivery_switch)
            customer_orders = @rider.customer_orders.where(distributor: @current_distributor, order_status_id: OrderStatus.where(order_type: order_status).ids)
            response = ShopothWarehouse::V1::Entities::CustomerOrderList.represent(
              paginate(Kaminari.paginate_array(customer_orders)),
            )
            success_response_with_json("Successfully fetched rider's customer_orders.", HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n\n#{__FILE__}Unable to fetch rider's customer_orders due to: #{error.message}"
            error!(failure_response_with_json("Unable to fetch rider's customer_orders.",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc 'Collect payment of customer orders of riders on DH panel.'
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
            customer_orders = @rider.customer_orders.joins(:payments).where(
              payments: { created_at: date_range, paymentable_type: 'User', receiver_type: 'Rider' },
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
                total_amount = order.payments.where(paymentable_type: 'User', receiver_type: 'Rider').sum(:currency_amount)
                @rider.payments.create!(currency_amount: total_amount,
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

        desc 'Receive customer orders from rider on DH panel.'
        put '/receive_order/:id' do
          customer_order = @current_distributor.customer_orders.find_by(id: params[:id])
          unless customer_order
            error!(failure_response_with_json('Customer order not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          rider = customer_order.rider
          unless rider.warehouse == @current_distributor.warehouse && rider.distributor == @current_distributor
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
          rider_id = customer_order.rider_id
          ActiveRecord::Base.transaction do
            prev_status = order_status
            status = order_status.in_transit_cancelled? ? OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled_at_dh]) : OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment])
            if order_status.in_transit_delivery_switch?
              partner_id = customer_order.next_partner_id
              shipping_type = customer_order.next_shipping_type
              rider_id = nil
            end
            update_stock(customer_order, @current_distributor.warehouse_id)
            customer_order.update!(status: status, changed_by: @current_staff, partner_id: partner_id,
                                   shipping_type: shipping_type, rider_id: rider_id)
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
