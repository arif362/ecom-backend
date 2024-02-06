# frozen_string_literal: true

module Ecommerce
  module V1
    class Feedbacks < Ecommerce::Base
      resource :feedbacks do
        desc 'create feedback'
        params do
          requires :message, type: String
          requires :rating, type: Integer
        end
        post do
          Feedback.create!(message: params[:message],
                           rating: params[:rating],
                           user: @current_user)
          success_response_with_json(I18n.t('Ecom.success.messages.contact_message_success'),
                                     HTTP_CODE[:CREATED],
                                     {})
        rescue StandardError => error
          Rails.logger.info "ecom: feedback create failed #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.contact_message_failure'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
