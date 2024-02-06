module ShopothPartner
  module V1
    class Passwords < ShopothPartner::Base
      helpers do
        def partner
          @partner ||= Partner.find_by_phone(params[:phone])
        end
      end

      resource :secret do
        desc 'Otp Generate'
        params do
          requires :phone, type: String
        end

        route_setting :authentication, optional: true
        post do
          if partner
            otp = SmsManagement::SendOtp.call(phone: partner.phone)
            if otp.success?
              respond_with_json(otp.token, HTTP_CODE[:CREATED])
            else
              error!(otp.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        end

        desc "Change partner's password."
        route_setting :authentication, optional: true
        put do
          otp = SmsManagement::VerifyOtp.call(phone: partner.phone, otp: params[:otp].to_i, token: params[:token])
          if otp.success?
            partner.update_attribute(:password, params[:password])
            respond_with_json(I18n.t('Partner.success.messages.password_changed'), HTTP_CODE[:OK])
          else
            error!(I18n.t('Partner.errors.messages.otp_mismatch'), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
