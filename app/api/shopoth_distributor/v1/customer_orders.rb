module ShopothDistributor
  module V1
    class CustomerOrders < ShopothDistributor::Base
      resource '/customer_orders' do
        desc 'customer order list'
        params do
          use :pagination, per_page: 50
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
          optional :order_id, type: Integer
          optional :schedule, type: String
          optional :shipping_type, type: String
          optional :status, type: String
          optional :business_type, type: String, values: CustomerOrder.business_types.keys
        end

        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
            error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          date_range = start_date_time..end_date_time
          customer_orders = @current_distributor.customer_orders.where(created_at: date_range).order(id: :desc)

          # filter using order_no, shipping_type, scheduled_date(partner), order_status, date_range

          customer_orders = customer_orders.where(business_type: params[:business_type]) if params[:business_type].present?
          customer_orders = customer_orders.where(id: params[:order_id]) if params[:order_id].present?
          customer_orders = customer_orders.where(shipping_type: params[:shipping_type]) if params[:shipping_type].present?
          customer_orders = customer_orders.joins(:partner).where(partners: { schedule: params[:schedule] }) if params[:schedule].present?
          customer_orders = customer_orders.joins(:status).where("LOWER(order_statuses.admin_order_status) = ?", params[:status].downcase) if params[:status].present?

          success_response_with_json('Successfully fetched customer list', HTTP_CODE[:OK],
                                     paginate(Kaminari.paginate_array(
                                                ShopothDistributor::V1::Entities::CustomerOrder.represent(customer_orders))))
        rescue StandardError => error
          Rails.logger.info "Unable to fetch customer orders due to, -#{error.message}"
          error!(failure_response_with_json('Unable to fetch customer orders',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Reconciled customer orders on DH panel.'
        params do
          use :pagination, per_page: 50
        end
        get '/reconciled' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
            error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          date_range = start_date_time..end_date_time
          customer_orders = @current_distributor.customer_orders.joins(:payments).where(
            payments: { created_at: date_range, paymentable_type: %w(Route Rider), receiver_type: 'Staff' },
          )
          order_response = ShopothWarehouse::V1::Entities::ReconciledOrders.represent(
            paginate(Kaminari.paginate_array(customer_orders.sort)),
          )
          total_collected_amount = customer_orders.joins(:payments).where(
            payments: { paymentable_type: %w(Route Rider), receiver_type: 'Staff' },
          ).sum(:currency_amount)

          total_deposited_amount = 0
          customer_orders.includes(:aggregated_transaction_customer_orders).distinct&.each do |order|
            next unless order.aggregated_transaction_customer_orders.customer_payment.present?

            total_deposited_amount += order.payments.successful.where(paymentable_type: %w(Route Rider), receiver_type: 'Staff')&.sum(:currency_amount) || 0
          end

          response = {
            total_collected_amount: total_collected_amount,
            total_deposited_amount: total_deposited_amount,
            due_amount: total_collected_amount - total_deposited_amount,
            orders: order_response,
          }
          success_response_with_json('Successfully fetched customer orders.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch customer orders due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch customer orders.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        route_param :id do
          before do
            @customer_order = @current_distributor.customer_orders.find_by(id: params[:id])
            unless @customer_order
              error!(failure_response_with_json('Customer order not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
          end

          desc 'Customer order details.'
          get do
            response = ShopothDistributor::V1::Entities::CustomerOrderDetails.represent(@customer_order)
            success_response_with_json('Successfully fetched customer order details.', HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.info "#{__FILE__} \nUnable to fetch customer order details due to, #{error.message}"
            error!(failure_response_with_json('Unable to fetch customer order details',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc 'Assign rider to customer_orders for DH Panel.'
          params do
            requires :rider_id, type: Integer
          end
          put '/assign_rider' do
            rider = @current_distributor.riders.find_by(id: params[:rider_id])
            warehouse_rider = @current_distributor.warehouse.riders.find_by(id: params[:rider_id])
            unless rider && warehouse_rider
              error!(failure_response_with_json('Rider not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end

            unless (@customer_order.home_delivery? || @customer_order.express_delivery?) && @customer_order.warehouse == @current_distributor.warehouse
              error!(failure_response_with_json("Rider can't be assigned to this order.",
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            statuses = OrderStatus.fetch_statuses(%w(ready_to_shipment))
            unless statuses.include?(@customer_order.status)
              error!(failure_response_with_json("Rider can't be assigned to this order.",
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            @customer_order.update!(rider_id: rider.id)
            success_response_with_json('Rider assigned successfully.', HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to assign rider to this order due to: #{error.message}"
            error!(failure_response_with_json('Unable to assign rider to this order.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
