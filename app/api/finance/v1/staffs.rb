# frozen_string_literal: true

module Finance
  module V1
    class Staffs < Finance::Base
      resource '/' do
        params do
          requires :email, type: String
          requires :password, type: String
        end

        desc 'Log in to finance staff.'
        route_setting :authentication, optional: true

        post 'login' do
          staff = Staff.finance.find_by(email: params[:email])
          if staff&.valid_password?(params[:password])
            respond_with_json(
              {
                token: JsonWebToken.encode(sub: staff.id),
                user_name: staff.name,
              }, HTTP_CODE[:OK]
            )
          else
            respond_with_json({ error: 'invalid' }, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
