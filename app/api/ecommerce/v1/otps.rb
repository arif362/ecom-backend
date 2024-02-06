module Ecommerce
  module V1
    class Otps < Ecommerce::Base
      helpers do
        def user
          @user ||= User.find_by(phone: params[:phone].strip)
        end
      end

      resources :otps do
        desc 'Send an OTP to given phone number.'
        route_setting :authentication, optional: true

        params do
          requires :phone, type: String
        end

        post '/send' do
          unless user.present?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_exists_error'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          if user.is_otp_verified
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_otp_verified_error'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          if SmsLog.otp.exit_sms_limit?(user.phone)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.too_many_otp_requests'),
                                              HTTP_CODE[:NOT_ACCEPTABLE], is_restricted: true),
                   HTTP_CODE[:NOT_ACCEPTABLE])
          end

          otp = user.change_otp
          user.update!(otp: otp)
          message = "Your One Time Password(OTP) for Shopoth is #{user.otp}"
          sms_context = SmsManagement::SendMessage.call(phone: user.phone, message: message)
          SmsLogJob.perform_later(SmsLog.sms_types[:otp],
                                  sms_context.phone,
                                  sms_context.message,
                                  sms_context.gateway_response)
          unless sms_context.success?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.otp_sent_failed'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
          success_response_with_json(I18n.t('Ecom.success.messages.otp_sent_successful'), HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nOTP sent failed due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.otp_sent_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Verify an otp.'
        route_setting :authentication, optional: true
        params do
          requires :phone, type: String
          requires :otp, type: String
        end
        post '/verify' do
          customer = User.find_by(phone: params[:phone], otp: params[:otp])
          unless customer.present?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.wrong_otp_error'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          customer.update!(verifiable: customer, is_otp_verified: true, verified_at: Time.now)
          success_response_with_json(I18n.t('Ecom.success.messages.otp_verified'), HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nOTP verification failed due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.otp_verify_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Send an OTP to change user phone number.'
        params do
          requires :phone, type: String
        end
        put '/phone_change_request' do
          # bd_phone is a gem method.It returns nil if phone number isn't valid else return valid phone number
          phone = params[:phone].to_s.bd_phone
          unless phone
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.phone_number_not_valid'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          existing_phone = User.find_by_phone(phone)
          if @current_user.phone == phone || existing_phone
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.phone_number_already_exists'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          if SmsLog.otp.exit_sms_limit?(user.phone)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.too_many_otp_requests'),
                                              HTTP_CODE[:NOT_ACCEPTABLE], is_restricted: true),
                   HTTP_CODE[:NOT_ACCEPTABLE])
          end
          @current_user.update!(temporary_otp: @current_user.change_otp, temporary_phone: phone)
          message = "Your One Time Password(OTP) for  Shopoth is #{@current_user.temporary_otp}"
          sms_context = SmsManagement::SendMessage.call(phone: @current_user.temporary_phone, message: message)
          SmsLogJob.perform_later(SmsLog.sms_types[:otp],
                                  sms_context.phone,
                                  sms_context.message,
                                  sms_context.gateway_response)
          unless sms_context.success?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.otp_sent_failed'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          success_response_with_json(I18n.t('Ecom.success.messages.otp_sent_successful'),
                                     HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nOTP sent failed due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.otp_sent_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Verify an otp to change user phone number.'
        params do
          requires :phone, type: String
          requires :otp, type: String
        end
        put '/phone_change_verify' do
          # bd_phone is a gem method.It returns nil if phone number isn't valid else return valid phone number
          phone = params[:phone].to_s.bd_phone
          unless phone
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.phone_number_not_valid'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          existing_phone = User.find_by_phone(phone)
          if @current_user.phone == phone || existing_phone
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.phone_number_already_exists'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          unless @current_user.temporary_phone == phone && @current_user.temporary_otp == params[:otp]
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.phone_or_otp_mismatched'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          @current_user.update!(phone: phone, temporary_otp: nil, temporary_phone: nil)
          response = Ecommerce::V1::Entities::AccountInformations.represent(@current_user)

          success_response_with_json(I18n.t('Ecom.success.messages.phone_change_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nOTP verification failed due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.phone_change_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'New Verify generate'
        route_setting :authentication, optional: true

        params do
          requires :token, type: String
        end

        post '/new_otp' do
          auth_key = AuthorizationKey.find_by(token: params[:token])
          otp = JsonWebToken.encode_otp(auth_key.user)
          if otp
            respond_with_json(otp.token, HTTP_CODE[:OK])
          else
            error!(otp.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue => err
          error!("Unable to process request #{err}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
