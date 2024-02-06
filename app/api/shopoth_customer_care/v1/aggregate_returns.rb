module ShopothCustomerCare
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
          aggregate_returns = AggregateReturn.where(created_at:
                                                      start_date_time.to_date.beginning_of_day..end_date_time.to_date.
                                                        end_of_day)
          if params[:order_no].present?
            aggregate_returns = aggregate_returns.joins(:customer_order).
                                where(customer_orders: { id: params[:order_id] })
          end

          if params[:return_status].present?
            aggregate_returns = aggregate_returns.joins(:return_customer_orders).
                                where(return_customer_orders: { return_status: params[:return_status] }).
                                distinct
          end
          return [] if aggregate_returns.empty?

          present paginate(Kaminari.paginate_array(aggregate_returns.includes(:warehouse, customer_order: :customer,).
                          order(created_at: :desc))),
                  with: ShopothCustomerCare::V1::Entities::AggregateReturn::AggregateReturns
        rescue StandardError => error
          Rails.logger.info "aggregate return fetch care-#{error.message}"
          error!(respond_with_json("Aggregate list fetch failed for #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        route_param :id do
          desc 'details of aggregate order'
          get do
            aggr_return = AggregateReturn.find(params[:id])
            present aggr_return, with: ShopothCustomerCare::V1::Entities::AggregateReturn::AggrDetails
          rescue StandardError => error
            Rails.logger.info "admin aggregate return details fetch failed for #{error.message}"
            error!(respond_with_json("Can not fetch due to #{error.message}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'reschedule the date for return from home'
          params do
            requires :reschedule_date, type: Date
          end
          put 'reschedule' do
            unless params[:reschedule_date].present?
              error!(respond_with_json('You have to select the date to reschedule',
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            aggr_return = AggregateReturn.where(refunded: false).find(params[:id])
            if aggr_return.return_customer_orders.from_home.empty?
              error!(respond_with_json('No rider is found to reschedule the pick up date',
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            aggr_return.update!(reschedule_date: params[:reschedule_date])
            respond_with_json('Successfully rescheduled', HTTP_CODE[:OK])
          rescue => error
            Rails.logger.info "can not be rescheduled from care: #{error.message}"
            error!(respond_with_json("Reschedule failed: #{error.message}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
