# frozen_string_literal: true

module Ecommerce
  module V1
    class UserModificationRequests < Ecommerce::Base
      resource :account_requests do
        desc 'Send Request List'
        get do
          user_modification_requests = @current_user.user_modification_requests
          success_response_with_json('Successfully Fetch Send Request List', HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::UserModificationRequests.represent(user_modification_requests))
        rescue StandardError => error
          Rails.logger.info "send request fetch error #{error.message}"
          error!(failure_response_with_json('Failed to fetch', HTTP_CODE[:UNPROCESSABLE_ENTITY], []),
                 HTTP_CODE[:OK])
        end


        desc 'Send Account Modification Request'
        params do
          requires :request_type, type: String, values: %w[deactivated deleted]
          requires :user_modify_reason_id, type: Integer
          optional :reason, type: String
        end
        post do
          unless @current_user.user_modification_requests.pending.blank?
            error!(failure_response_with_json('Pending request exists',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          user_modification_request = @current_user.user_modification_requests.create!(declared(params))
          success_response_with_json('Successfully Send Request', HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::UserModificationRequests.represent(user_modification_request))
        rescue StandardError => error
          Rails.logger.info "send request error #{error.message}"
          error!(failure_response_with_json('Failed to send request', HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
