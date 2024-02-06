# frozen_string_literal: true

module ThirdPartyService
  module V1
    class ThirdPartyUsers < ThirdPartyService::Base
      resource '/' do
        params do
          requires :username, type: String
          requires :password, type: String
        end

        desc 'Log in to third_party staff.'
        route_setting :authentication, optional: true

        post 'login' do
          third_party_user = Staff.three_ps.find_by(email: params[:username])
          unless third_party_user
            error!(failure_response_with_json('Staff not found', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end
          unless third_party_user.staffable_type == 'ThirdPartyUser' && third_party_user.staffable.active?
            error!(failure_response_with_json('Invalid.', HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          if third_party_user.valid_password?(params[:password])
            success_response_with_json(
              'Successfully logged in.',
              HTTP_CODE[:OK],
              {
                token: JsonWebToken.single_login_token_encode(third_party_user),
                name: third_party_user.first_name,
                username: third_party_user.email,
              }
            )
          else
            failure_response_with_json('Invalid username or password', HTTP_CODE[:FORBIDDEN])
          end
        end
      end
    end
  end
end
