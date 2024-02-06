# frozen_string_literal: true

module ShopothCustomerCare
  module V1
    class CustomerCareAgents < ShopothCustomerCare::Base

      resource '/' do
        params do
          requires :email, type: String
          requires :password, type: String
        end

        desc 'Log in a customer care agent'
        route_setting :authentication, optional: true

        post '/login' do
          staff = Staff.customer_care.find_by(email: params[:email])
          unless staff
            error!(failure_response_with_json('Not found', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end
          unless staff.staffable_type == 'CustomerCareAgent' && staff.staffable.active?
            error!(failure_response_with_json('Invalid.', HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          unless staff.valid_password?(params[:password])
            error!(failure_response_with_json('Invalid.', HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          response = {
            token: JsonWebToken.login_token_encode(staff),
          }
          success_response_with_json('Successfully logged in.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nLogin failed due to: #{error.message}"
          error!(failure_response_with_json('Login failed.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])

        end

      end
    end
  end
end
