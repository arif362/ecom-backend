# frozen_string_literal: true

module ShopothDistributor
  module V1
    class RetailerAssistants < ShopothDistributor::Base
      resource '/retailer_assistants' do
        desc 'Get all retailer assistants.'
        params do
          use :pagination, per_page: 50
        end
        get do
          ra_lists = @current_distributor.retailer_assistants
          success_response_with_json('Successfully fetched retailer assistants',
                                     HTTP_CODE[:OK],
                                     paginate(Kaminari.paginate_array(
                                                ShopothDistributor::V1::Entities::RetailerAssistants.represent(ra_lists))))

        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch retailer assistants due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch retailer assistants', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Return a ra'
        route_param :id do
          get do
            retailer_assistant = @current_distributor.retailer_assistants.find_by(id: params[:id])
            unless retailer_assistant
              error!(failure_response_with_json('Retailer assistant not Found', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
            success_response_with_json('Successfully fetched retailer assistant',
                                       HTTP_CODE[:OK],
                                       ShopothDistributor::V1::Entities::RetailerAssistantDetails.represent(retailer_assistant))

          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch retailer assistant due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch retailer assistant', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
