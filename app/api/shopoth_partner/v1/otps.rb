module ShopothPartner
  module V1
    class Otps < ShopothPartner::Base
      namespace :otps do
        desc 'Sends an OTP to given phone number and returns encrypted hash'
        route_setting :authentication, type: RetailerAssistant

        route_param :id do
          post '/send' do
            partner = Partner.find(params[:id])
            if SmsLog.otp.exit_sms_limit?(partner.phone)
              error!(I18n.t('Ecom.errors.messages.too_many_otp_requests'), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            otp_context = SmsManagement::SendOtp.call(phone: partner.phone)
            SmsLogJob.perform_later(SmsLog.sms_types[:otp],
                                    otp_context.phone,
                                    otp_context.message,
                                    otp_context.gateway_response)
            if otp_context.success?
              respond_with_json(otp_context.token, HTTP_CODE[:OK])
            else
              error!(otp_context.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        end

        desc 'Verify an otp'
        route_setting :authentication, type: RetailerAssistant

        params do
          requires :phone, type: String
          requires :otp, type: String
          requires :token, type: String
        end

        helpers do
          def user
            @user ||= Partner.find_by!(phone: params[:phone])
          end
        end

        post '/verify' do
          otp = SmsManagement::VerifyOtp.call(phone: params[:phone], otp: params[:otp].to_i, token: params[:token])

          if otp.success?
            token = JsonWebToken.encode(partner_id: user.id, retailer_id: @current_retailer.id)
            respond_with_json('verified', HTTP_CODE[:OK]).merge(token: token)
          else
            error!(respond_with_json('Wrong OTP', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

        rescue StandardError => error
          error!('Wrong OTP', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
