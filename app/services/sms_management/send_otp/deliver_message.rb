require 'net/http'
require 'json'


module SmsManagement
  class SendOtp
    class DeliverMessage
      include Interactor

      delegate :phone, :message, :gateway_response, to: :context

      MESSAGE_STATUS = {
        failed: -1,
        pending: 0,
        successful: 1,
        processing: 2,
      }.freeze

      def call
        context.otp = otp
        context.message = message
        response = call_api

        Rails.logger.info "<<<<<<<<<<<<<<<  Sms response from smart lab end >>>>>>>>>>>>>>>>"
        Rails.logger.info "Sms response from smart lab: #{response}"
        Rails.logger.info "<<<<<<<<<<<<<<<<<<<<<<<<< Sms response from smart lab end >>>>>>>>>>>>>>>>>>>>>>>"

        context.gateway_response = response
        context.fail!(error: response[:response]) if response[:response].to_i != 0
      end

      def call_api
        url = URI.parse(URI.escape(api_url))
        response = Net::HTTP.get_response(url)
        JSON.parse(response.read_body)
      end

      private

      def otp
        @otp ||= rand(10_000..99_999)
      end

      def api_url
        "#{ENV['SMART_LAB_API_URL']}?api_key=#{ENV['SMART_LAB_API_KEY']}&user=#{ENV['SMART_LAB_API_USER_NAME']}&password=#{ENV['SMART_LAB_API_PASSWORD']}&sender=#{ENV['SMART_LAB_SMS_SENDER']}&msisdn=#{phone}&smstext=#{message}"
      end

      def message
        "Your One Time Password(OTP) for Shopoth is #{otp}"
      end
    end
  end
end
