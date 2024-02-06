module ShopothDistributor
  module V1
    class AggregateReturns < ShopothDistributor::Base
      resource :aggregate_returns do
        desc 'fetch return orders'
        params do
          use :pagination, per_page: 50
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : 3.months.ago
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : Time.now
          aggregate_returns = @current_distributor.aggregate_returns.
                              where(created_at: start_date_time.to_date.beginning_of_day..end_date_time.to_date.
                                    end_of_day)
          aggregate_returns = aggregate_returns.where(customer_order_id: params[:order_id]) if params[:order_id].present?

          success_response_with_json('Successfully fetched', HTTP_CODE[:OK],
                                     paginate(Kaminari.paginate_array(
                                                ShopothDistributor::V1::Entities::AggregateReturns.represent(
                                                  aggregate_returns.order(created_at: :desc)))))
        rescue StandardError => error
          Rails.logger.info "Unable to fetch aggregate returns list due to#{error.message}"
          error!(failure_response_with_json('Unable to fetch aggregate returns list',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        route_param :id do
          desc 'Aggregate Return Details'
          get do
            aggregate_return = @current_distributor.warehouse.aggregate_returns.find(params[:id])
            success_response_with_json('Successfully fetched', HTTP_CODE[:OK],
                                       ShopothDistributor::V1::Entities::AggrDetails.represent(aggregate_return))
          rescue StandardError => error
            Rails.logger.info "Unable to fetch aggregate return due to, #{error.message}"
            error!(failure_response_with_json('Unable to fetch aggregate return',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          params do
            requires :rider_id, type: Integer
          end
          put 'rider_assign' do
            aggregate_return = @current_distributor.warehouse.
                               aggregate_returns.where(refunded: false).find(params[:id])
            rider = @current_distributor.riders.find(params[:rider_id])
            aggregate_return.update!(rider: rider)
            aggregate_return.return_customer_orders.update_all(rider_id: rider.id)
            success_response_with_json('Successfully rider assigned', HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.info "Unable to assign rider due to #{error.message}"
            error!(failure_response_with_json('Unable to assign rider',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
