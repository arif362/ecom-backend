class PasswordsController < Devise::PasswordsController
  respond_to :json
  def create
    if user
      otp = JsonWebToken.encode_otp(user)
      if otp
        render json: { message: otp.token, status: 200 }
      else
        render json: { errors: otp.error }
      end
    else
      render json: { errors: "User not registered" }
    end
  end

  def update
    otp = JsonWebToken.verify_otp(params[:token], params[:otp])
    if otp.present?
      if !otp.is_expired?
        if params[:password].present? && params[:password].length >= 6
          user.update_attribute(:password, params[:password])
          render json: { message: 'Password Update', status: 200 }
        else
          render json: { message: 'Password Cannot Update!', status: 406 }
        end
      else
        render json: { error: 'OTP is expired, request to a new otp', status: 406 }
      end
    else
      render json: { error: 'OTP does not match!', status: 422 }
    end
  end

  private

  def user
    @user ||= User.find_by_email_or_phone(params[:email_or_phone])
  end
end
