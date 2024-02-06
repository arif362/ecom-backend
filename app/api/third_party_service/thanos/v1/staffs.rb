# frozen_string_literal: true

module ThirdPartyService
  module Thanos
    module V1
      class Staffs < Thanos::Base
        resource '/' do
          params do
            requires :username, type: String
            requires :password, type: String
          end

          desc 'Log in as thanos user'
          route_setting :authentication, optional: true

          post 'login' do
            thanos_user = Staff.three_ps.find_by(email: params[:username])
            unless thanos_user
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json('Staff not found', HTTP_CODE[:NOT_ACCEPTABLE]),
                                             thanos_user,
                                             false)
              error!(failure_response_with_json('Staff not found', HTTP_CODE[:NOT_ACCEPTABLE]),
                     HTTP_CODE[:OK])
            end
            unless thanos_user.staffable_type == 'ThirdPartyUser' &&
                   thanos_user.staffable.active? && thanos_user.staffable.thanos?
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json('Invalid.', HTTP_CODE[:NOT_ACCEPTABLE]),
                                             thanos_user,
                                             false)
              error!(failure_response_with_json('Invalid.', HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            if thanos_user.valid_password?(params[:password])
              token = JsonWebToken.single_login_token_encode(thanos_user)
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             success_response_with_json('Successfully logged in.', HTTP_CODE[:OK],
                                                                        {
                                                                          token: token,
                                                                          expired_at: thanos_user.authorization_key.expiry.strftime('%FT%T%:z'),
                                                                        }),
                                             thanos_user,
                                             true)
              success_response_with_json('Successfully logged in.', HTTP_CODE[:OK],
                                         {
                                           token: token,
                                           expired_at: thanos_user.authorization_key.expiry.strftime('%FT%T%:z'),
                                         })
            else
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json('Invalid username or password',
                                                                        HTTP_CODE[:NOT_ACCEPTABLE]),
                                             thanos_user,
                                             false)
              failure_response_with_json('Invalid username or password', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end
        end
      end
    end
  end
end
