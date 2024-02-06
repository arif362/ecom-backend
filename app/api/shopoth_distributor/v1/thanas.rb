module ShopothDistributor
  module V1
    class Thanas < ShopothDistributor::Base

      resource :thanas do
        desc 'Thana list for current distributor'
        params do
          optional :home_delivery, type: Boolean
        end
        get '/search' do
          thanas = @current_distributor.thanas
          success_response_with_json('Successfully fetched', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Thanas.represent(thanas))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch thana list due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch thana list', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
