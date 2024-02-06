# frozen_string_literal: true

module Ecommerce
  module V1
    class UserModifyReasons < Ecommerce::Base
      helpers do
        def deactivation_note
          note = Article.find_by(slug: 'account-deactivation-note')
          {
            body: note&.body || '',
            bn_body: note&.bn_body || '',
          }
        end
      end
      resource :modify_reasons do
        desc 'Reasons List'
        get do
          user_modify_reasons = UserModifyReason.deactivated_or_deleted
          user_modify_reasons = Ecommerce::V1::Entities::UserModifyReasons.represent(user_modify_reasons)
          response = {
            deactivation_note: deactivation_note,
            reason: user_modify_reasons,
          }
          success_response_with_json('Successfully fetched reason list', HTTP_CODE[:OK],
                                     response)
        rescue StandardError => error
          Rails.logger.info "Unable to fetch due to, #{error.message}"
          error!(failure_response_with_json('Failed to fetch', HTTP_CODE[:UNPROCESSABLE_ENTITY], []),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
