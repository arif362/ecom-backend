
module ThirdPartyService
  module Thanos
    module V1
      class ProductAttributes < Thanos::Base
        resource :product_attributes do
          params do
            use :pagination, per_page: 50
          end
          desc 'Return list of product attributes'
          get do
            product_attributes = ProductAttribute.all
            success_response_with_json('Successfully fetched product attributes list', HTTP_CODE[:OK],
                                       paginate(Kaminari.paginate_array(product_attributes)))
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch list due to: #{error.full_message}"
            ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                           failure_response_with_json("Unable to fetch list.  #{error.message}",
                                                                      HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                                           @current_staff,
                                           false)
            error!(failure_response_with_json("Unable to fetch list due to, #{error.message}",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
