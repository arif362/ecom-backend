module Ecommerce
  module V1
    class CustomerAcquisitions < Ecommerce::Base
      resource :customer_acquisitions do
        before do
          unless @current_user&.ambassador.present?
            error!(failure_response_with_json(I18n.t('common.errors.messages.access_denied_instead_ambassador'), HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:OK])
          end
        end

        desc 'Customer Acquisitions'
        params do
          requires :full_name, type: String
          requires :phone, type: String
          requires :gender, type: String, values: %w[female male others]
          requires :date_of_birth, type: Date
          optional :preferred_name, type: String
        end
        post do
          acquisition_data = CustomerAcquisition.add_acquisition(declared(params, include_missing: false), @current_user, @locale)
         success_response_with_json(I18n.t('common.success.messages.customer_acquire'), HTTP_CODE[:CREATED], acquisition_data)
        rescue StandardError => error
          Rails.logger.info "Unable to complete customer acquisition due to #{error.message}."
          error!(failure_response_with_json(I18n.t('common.errors.messages.customer_acquire') + error.message,
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Verify OTP'
        route_param :id do
          params do
            requires :otp, type: String
          end
          put :otp_verify do
            user = User.find(params[:id])
            CustomerAcquisition.verify_otp(params[:otp], user, @current_user, @locale)
            success_response_with_json(I18n.t('common.success.messages.otp_verify'), HTTP_CODE[:OK])
          rescue ActiveRecord::RecordNotFound
            error!(failure_response_with_json(I18n.t('common.errors.messages.acquisition_not_found'), HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.info "Unable to verify otp due to #{error.message}."
            error!(failure_response_with_json(I18n.t('common.errors.messages.otp_verify'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end

        desc 'Greetings(Thanks Button) For Customer Acquisition'
        route_param :id do
          get :greetings do
            user = User.find(params[:id])
            unless user.customer_acquisition.present?
              error_message = I18n.t('common.errors.messages.otp_not_verified') unless user&.is_otp_verified
              error!(failure_response_with_json(error_message || I18n.t('common.errors.messages.acquisition_not_found'), HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
            user.customer_acquisition.send_greetings(@current_user, @locale)
            success_message = Coupon.first_registration&.active&.last&.running? ? I18n.t('common.success.messages.customer_acquire_greetings') :
                                I18n.t('common.success.messages.customer_acquire_greetings_without_voucher')
            success_response_with_json(success_message, HTTP_CODE[:OK])
          rescue ActiveRecord::RecordNotFound
            error!(failure_response_with_json(I18n.t('common.errors.messages.acquisition_not_found'), HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.info "Unable to complete the registration process due to #{error.message}."
            error!(failure_response_with_json(I18n.t('common.errors.messages.customer_acquire_greetings') + error.message,
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end

        desc 'Remote uniqueness check for customer acquisition.'
        params do
          requires :content, type: String
          requires :field_name, type: String, values: %w[phone whatsapp viber imo nid]
        end
        get :remote_uniqueness_and_validation_check do
          validation = User.remote_uniqueness_and_validation_check(params[:content], params[:field_name])
          success_response_with_json('Successfully check remote uniqueness and validation.', HTTP_CODE[:OK], {validate: validation})
        rescue StandardError => error
          Rails.logger.info "Unable to check remote uniqueness and validation due to #{error.message}."
          error!(failure_response_with_json("Unable to check remote uniqueness and validation due to #{error.message}.",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Update Customer Additional Info'
        route_param :id do
          params do
            optional :whatsapp, type: String
            optional :viber, type: String
            optional :imo, type: String
            requires :home_address, type: String
            requires :nid, type: String
          end
          put do
            user = User.find(params[:id])
            unless user.customer_acquisition.present?
              error_message = I18n.t('common.errors.messages.otp_not_verified') unless user&.is_otp_verified
              error!(failure_response_with_json(error_message || I18n.t('common.errors.messages.acquisition_not_found'), HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
            user.customer_acquisition.update_additional_info(declared(params, include_missing: false), @current_user, @locale)
            success_response_with_json(I18n.t('common.success.messages.customer_acquire_additional_info'), HTTP_CODE[:OK])
          rescue ActiveRecord::RecordNotFound
            error!(failure_response_with_json(I18n.t('common.errors.messages.acquisition_not_found'), HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.info "Unable to update customer info due to #{error.message}"
            error!(failure_response_with_json(I18n.t('common.errors.messages.customer_acquire_additional_info') + error.message,
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
