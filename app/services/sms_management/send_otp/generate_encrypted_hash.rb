module SmsManagement
  class SendOtp
    class GenerateEncryptedHash
      include Interactor

      delegate :phone, :otp, to: :context

      def call
        context.token = JsonWebToken.encode payload
      end

      private

      def payload
        {
          phone: phone,
          otp: otp,
        }
      end
    end
  end
end
