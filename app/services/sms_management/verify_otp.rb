module SmsManagement
  class VerifyOtp
    include Interactor

    delegate :phone, :otp, :token, :customer, to: :context

    def call
      error! 'OTP expired!' unless payload['exp'] >= Time.now.to_i
      error! 'something not right!' unless payload['phone'] == phone
      error! 'OTP did not match, please try again!' unless payload['otp'] == otp
    end

    private

    def payload
      @payload ||= JsonWebToken.decode token
    end

    def error!(message)
      context.fail!(error: message)
    end
  end
end
