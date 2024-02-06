# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class Feedbacks < Ecommerce::Base
      resource :feedbacks do
        desc 'feedbacks fetch'
        params do
          use :pagination, per_page: 50
        end
        get do
          unless check_wh_warehouse
            error!(failure_response_with_json('Not authorized to see',
                                              HTTP_CODE[:NOT_ACCEPTABLE], {}),
                   HTTP_CODE[:OK])
          end
          # TODO: Need to Optimize Query
          feedbacks = paginate(Kaminari.paginate_array(Feedback.includes(:user).order(id: :desc)))
          success_response_with_json('Successfully fetched',
                                     HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Feedbacks.represent(feedbacks))
        rescue StandardError => error
          Rails.logger.info "admin: feedback fetch failed #{error.message}"
          error!(failure_response_with_json('Failed to fetch feedbacks',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
