# frozen_string_literal: true

module ShopothCustomerCare
  module V1
    class UserModificationRequests < ShopothCustomerCare::Base

      resource :modify_reasons do
        desc 'Reasons List'
        get do
          user_modify_reasons = UserModifyReason.activated
          user_modify_reasons = Ecommerce::V1::Entities::UserModifyReasons.represent(user_modify_reasons)
          success_response_with_json('Successfully fetched reason list', HTTP_CODE[:OK],
                                     user_modify_reasons)
        rescue StandardError => error
          Rails.logger.info "Unable to fetch due to, #{error.message}"
          error!(failure_response_with_json('Failed to fetch', HTTP_CODE[:UNPROCESSABLE_ENTITY], []),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
