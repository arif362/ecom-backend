module ShopothWarehouse
  module V1
    class AggregateReturns < ShopothWarehouse::Base
      resource :aggregate_returns do
        desc 'fetch return orders'
        params do
          use :pagination, per_page: 50
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : 3.months.ago
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : Time.now
          aggregate_returns = if check_dh_warehouse
                                @current_staff.warehouse.aggregate_returns.
                                  where(created_at: start_date_time.to_date.beginning_of_day..end_date_time.to_date.
                                    end_of_day)
                              else
                                AggregateReturn.all.
                                  where(created_at: start_date_time.to_date.beginning_of_day..end_date_time.to_date.
                                    end_of_day)
                              end

          aggregate_returns = params[:order_id].present? ? aggregate_returns.where(customer_order_id: params[:order_id]) : aggregate_returns
          return [] if aggregate_returns.empty?
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(aggregate_returns.order(created_at: :desc))),
                  with: ShopothWarehouse::V1::Entities::AggregateReturns
        rescue StandardError => error
          Rails.logger.info "aggregate return fetch-admin-#{error.message}"
          error!(respond_with_json("Aggregate list fetch failed for #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        route_param :id do
          desc 'details of aggregate order'
          get do
            aggr_return = if check_dh_warehouse
                            @current_staff.warehouse.aggregate_returns.find(params[:id])
                          else
                            AggregateReturn.find(params[:id])
                          end
            present aggr_return, with: ShopothWarehouse::V1::Entities::AggrDetails
          rescue StandardError => error
            Rails.logger.info "admin aggregate return details fetch failed for #{error.message}"
            error!(respond_with_json("Can not fetch due to #{error.message}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'assign rider'
          params do
            requires :rider_id, type: Integer
          end
          put 'rider_assign' do
            aggr_return = @current_staff.warehouse.aggregate_returns.where(refunded: false).find(params[:id])
            rider = aggr_return.customer_order.distributor.riders.find(params[:rider_id])
            aggr_return.update!(rider_id: rider.id)
            aggr_return.return_customer_orders.update_all(rider_id: rider.id)
            respond_with_json('Successfully assigned', HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.info "admin aggregate return rider assign failed for #{error.message}"
            error!(respond_with_json('Unable to assign due to can not find the aggregate order',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
