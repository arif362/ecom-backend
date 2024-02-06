module Ecommerce
  module V1
    class Ambassadors < Ecommerce::Base
      resource :ambassadors do
        desc 'Remote uniqueness check for ambassadoprs.'
        params do
          requires :content, type: String
          requires :field_name, type: String, values: %w[bkash_number whatsapp viber imo]
        end
        get :remote_uniqueness_and_validation_check do
          validation = Ambassador.remote_uniqueness_and_validation_check(params[:content], params[:field_name])
          success_response_with_json('Successfully check remote uniqueness and validation.', HTTP_CODE[:OK], {validate: validation})
        rescue StandardError => error
          Rails.logger.info "Unable to check remote uniqueness and validation due to #{error.message}."
          error!(failure_response_with_json("Unable to check remote uniqueness and validation due to #{error.message}.",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'edit an ambassador'
        params do
          optional :bkash_number, type: String
          optional :whatsapp, type: String
          optional :viber, type: String
          optional :imo, type: String
          optional :preferred_name, type: String
        end
        put do
          ambassador = @current_user.ambassador
          unless ambassador
            error!(failure_response_with_json('Ambassador not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          ambassador.update!(declared(params, include_missing: false))
          success_response_with_json('Successfully edited', HTTP_CODE[:OK])

        rescue StandardError => error
          Rails.logger.info "Ambassador edit error #{error.message}"
          error!(failure_response_with_json("Failed to edit ambassador due to #{error.message}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'create ambassador'
        params do
          requires :bkash_number, type: String
          optional :whatsapp, type: String
          optional :viber, type: String
          optional :imo, type: String
          requires :preferred_name, type: String
        end
        post do
          if @current_user&.ambassador.present?
            error!(failure_response_with_json(I18n.t('common.errors.messages.ambassador_exist'), HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          @current_user.update_as_ambassador!(declared(params, include_missing: false))
          success_response_with_json(I18n.t('common.success.messages.updated_as_ambassador'), HTTP_CODE[:CREATED])

        rescue StandardError => error
          Rails.logger.info "Unable to registered as ambassador due to #{error.message}."
          error!(failure_response_with_json(I18n.t('common.errors.messages.updated_as_ambassador') + error.message,
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
