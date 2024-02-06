class RegistrationsController < Devise::SessionsController
  respond_to :json

  def create
    @user = User.new(sign_up_params)
    if @user.save
      render json: {
        first_name: @user.first_name,
        last_name: @user.last_name,
        phone: @user.phone,
        email: @user.email,
      }
    else
      render json: { errors: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.permit(:first_name, :last_name, :email, :phone, :password, :password_confirmation)
  end
end
