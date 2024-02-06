module ShopothDistributor
  module V1
    class ReturnOrders < ShopothDistributor::Base
      helpers ShopothCustomerCare::V1::Serializers::ReturnOrderSerializer

      resource '/return_orders' do
        desc 'return customer orders list'
        params do
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
          optional :order_id, type: Integer
          use :pagination, per_page: 50
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.at_beginning_of_day : Time.now.at_beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now
          date_range = start_date_time..end_date_time
          return_orders = @current_distributor.return_customer_orders.packed.where(created_at: date_range).order(id: :desc)

          return_orders = return_orders.where(customer_order_id: params[:order_id]) if params[:order_id].present?

          success_response_with_json('Successfully fetched customer list', HTTP_CODE[:OK],
                                     paginate(Kaminari.paginate_array(
                                                ShopothDistributor::V1::Entities::ReturnOrders.represent(return_orders))))

        rescue StandardError => error
          Rails.logger.info "Unable to fetch return orders due to, -#{error.message}"
          error!(failure_response_with_json('Unable to fetch return orders',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get a specific return_order details.'
        route_param :id do
          before do
            @return_order = @current_distributor.return_customer_orders.find_by(id: params[:id])
            unless @return_order
              error!(failure_response_with_json('Return order not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
          end

          get do
            success_response_with_json('Successfully fetched return order details', HTTP_CODE[:OK],
                                       return_details_customer(@return_order))
          rescue StandardError => error
            Rails.logger.info "\n#{__FILE__} \nUnable to fetch return order details due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch return order details',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc 'Receive return orders from Rider/SR.'
          put '/receive' do
            distributor = @return_order.aggregate_return&.rider&.distributor || @return_order.partner&.route&.distributor
            unless @return_order.in_transit? && distributor == @current_distributor
              error!(failure_response_with_json("Return order can't be received.",
                                                HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
            end
            ActiveRecord::Base.transaction do
              @return_order.update!(return_status: :delivered_to_dh, qc_status: :pending, changeable: @current_staff)
              @return_order.update_inventory_and_stock_changes('return_in_dh_quantity', 'return_in_transit_quantity')
              @current_distributor.warehouse.update(return_count: (@current_distributor.warehouse.return_count.to_i + 1))
            end
            success_response_with_json('Return order received successfully.', HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to receive return order due to: #{error.message}"
            error!(failure_response_with_json('Unable to receive return order.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc 'Assigning riders to return_order by DH admin.'
          params do
            requires :rider_id, type: Integer
          end

          post 'assign_rider' do
            return_order = ReturnCustomerOrder.find(params[:id])
            rider = Rider.find(params[:rider_id])
            return_order.update!(rider_id: rider.id) unless rider.blank?
            return_order.aggregate_return.update(rider_id: rider.id)
            success_response_with_json('Successfully assigned rider.', HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to assign rider due to: #{error.message}"
            error!(failure_response_with_json('Unable to assign rider due to.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
