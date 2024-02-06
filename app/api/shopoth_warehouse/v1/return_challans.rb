module ShopothWarehouse
  module V1
    class ReturnChallans < ShopothWarehouse::Base
      resource :return_challans do
        desc 'Get all ReturnChallans.'
        params do
          use :pagination, per_page: 50
          optional :status, type: String, values: ReturnChallan.statuses.keys
          optional :distributor_id, type: Integer
        end
        get do
          return_challans = @current_staff.warehouse.return_challans.order(id: :desc)
          return_challans = return_challans.where(distributor_id: params[:distributor_id]) if params[:distributor_id].present?
          return_challans = return_challans.where(status: params[:status]) if params[:status].present?
          # TODO: Need to Optimize Query
          return_challans = paginate(Kaminari.paginate_array(return_challans))
          return_challans = ShopothWarehouse::V1::Entities::ReturnChallans.represent(return_challans, list: true)

          success_response_with_json('ReturnChallans fetched successfully', HTTP_CODE[:OK], return_challans)

        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch ReturnChallans due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch ReturnChallans.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get a specific ReturnChallan.'
        route_param :id do
          get do
            return_challan = ReturnChallan.includes(:customer_orders, return_customer_orders: [{ shopoth_line_item: { variant: :product } }]).find(params[:id])
            return_challan = ShopothWarehouse::V1::Entities::ReturnChallans.represent(return_challan)
            success_response_with_json('ReturnChallan fetched successfully', HTTP_CODE[:OK], return_challan)
          rescue ::ActiveRecord::RecordNotFound
            error!(failure_response_with_json('ReturnChallan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch ReturnChallan details due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch ReturnChallan details.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end


        desc 'Receive return challan.'
        route_param :id do
          params do
            optional :cancelled_order_ids, type: Array
            optional :returned_order_ids, type: Array
          end
          put :received do
            return_challan = ReturnChallan.find(params[:id])
            return_challan.receive!(params[:cancelled_order_ids] || [], params[:returned_order_ids] || [], @current_staff)
            return_challan = ShopothWarehouse::V1::Entities::ReturnChallans.represent(return_challan)
            success_response_with_json('ReturnChallan receive successfully', HTTP_CODE[:OK], return_challan)
          rescue ::ActiveRecord::RecordNotFound
            error!(failure_response_with_json('ReturnChallan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to receive ReturnChallan due to: #{error.full_message}"
            error!(failure_response_with_json('Unable to receive ReturnChallan.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
