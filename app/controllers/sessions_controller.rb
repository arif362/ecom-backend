class SessionsController < Devise::SessionsController
  def create
    unless user&.valid_password?(params[:password])
      return render json: { errors: 'invalid email, phone or password' }, status: :unprocessable_entity
    end
    unless user.is_otp_verified
      return render json: { errors: 'OTP verification not done yet', is_otp_verified: user&.is_otp_verified, phone: user&.phone }, status: :unprocessable_entity
    end

    if user.shopoth? && domain == "#{ENV['MEMBER_WAREHOUSE']}"
      render json: { errors: 'Invalid email or phone for this site' }, status: :unprocessable_entity
    else
      render json: {
        success: true,
        status: 200,
        message: 'Successfully logged in.',
        data: {
          token: JsonWebToken.user_token_encode(user),
          name: user.full_name,
          phone: user.phone,
        },
      }
    end
  end

  private

  def user
    @user ||= User.find_by_email_or_phone(params[:email_or_phone])
  end

  def domain
    request.headers.fetch('Sub-Domain', '').split(' ').last
  end
end
