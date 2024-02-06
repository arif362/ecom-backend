# frozen_string_literal: true

module ShopothCorporateUser
  module V1
    class CorporateUsers < ShopothCorporateUser::Base
      resource :corporate_users do
        params do
          requires :email, type: String
          requires :password, type: String
        end

        desc 'Log in a corporate_user'
        route_setting :authentication, optional: true

        post '/login' do
          corporate_user = CorporateUser.find_by(email: params[:email])
          if corporate_user&.valid_password?(params[:password])
            respond_with_json(
              {
                token: JsonWebToken.encode(sub: corporate_user.id),
                name: corporate_user.name,
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
