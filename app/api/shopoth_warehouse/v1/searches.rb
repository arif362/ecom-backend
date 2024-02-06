# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class Searches < ShopothWarehouse::Base
      resource :searches do
        params do
          use :pagination, per_page: 50
        end
        desc 'Get all search key words.'
        get do
          searches = if check_dh_warehouse
                       @current_staff.warehouse.searches
                     else
                       Search.all
                     end
          # TODO: Need to Optimize Query
          response = ShopothWarehouse::V1::Entities::Searches.represent(paginate(Kaminari.paginate_array(searches)))
          success_response_with_json('Successfully fetched searches.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetched searches due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetched searches.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
