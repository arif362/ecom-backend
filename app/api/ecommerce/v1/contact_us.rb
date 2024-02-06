# frozen_string_literal: true

module Ecommerce
  module V1
    class ContactUs < Ecommerce::Base
      namespace :contact_us do
        desc 'create message'
        params do
          requires :name, type: String
          requires :phone, type: String
          requires :email, type: String
          requires :message, type: String
        end
        route_setting :authentication, optional: true
        post do
          phone = params[:phone].to_s.bd_phone
          unless phone
            error!(failure_response_with_json('Please provide a valid phone number.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:OK])
          end
          Contact.create!(declared(params))
          success_response_with_json(I18n.t('Ecom.success.messages.contact_message_success'),
                                     HTTP_CODE[:CREATED],
                                     {})
        rescue StandardError => error
          Rails.logger.info "ecom: message create failed #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.contact_message_failure'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
