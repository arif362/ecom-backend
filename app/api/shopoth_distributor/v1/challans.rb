module ShopothDistributor
  module V1
    class Challans < ShopothDistributor::Base
      resource :challans do
        desc 'Get all Challans.'
        params do
          use :pagination, per_page: 50
          optional :status, type: String, values: Challan.statuses.keys
        end
        get do
          challans = @current_distributor.challans.order(id: :desc)
          challans = challans.where(status: params[:status]) if params[:status].present?
          # TODO: Need to Optimize Query
          challans = paginate(Kaminari.paginate_array(challans))
          challans = ShopothDistributor::V1::Entities::Challans.represent(challans, list: true)

          success_response_with_json('Challans fetched successfully', HTTP_CODE[:OK], challans)

        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch Challans due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch Challans.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get a specific Challan.'
        route_param :id do
          get do
            challan = Challan.find(params[:id])
            challan = ShopothDistributor::V1::Entities::Challans.represent(challan)
            success_response_with_json('Challan fetched successfully', HTTP_CODE[:OK], challan)
          rescue ::ActiveRecord::RecordNotFound
            error!(failure_response_with_json('Challan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch Challan details due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch Challan details.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end


        desc 'Receive challan.'
        route_param :id do
          params do
            requires :order_ids, type: Array do
              requires type: Integer
            end
          end
          put :received do
            challan = Challan.find(params[:id])
            challan.receive!(params[:order_ids], @current_staff)
            challan = ShopothDistributor::V1::Entities::Challans.represent(challan)
            success_response_with_json('Challan receive successfully', HTTP_CODE[:OK], challan)
          rescue ::ActiveRecord::RecordNotFound
            error!(failure_response_with_json('Challan not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to receive Challan due to: #{error.full_message}"
            error!(failure_response_with_json("Unable to receive Challan due to: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
