# frozen_string_literal: true

module ShopothDistributor
  module V1
    class Distributors < ShopothDistributor::Base
      resource '/' do
        desc 'Distributor staff login.'
        params do
          requires :email, type: String
          requires :password, type: String
        end
        route_setting :authentication, optional: true
        post '/sign_in' do
          staff = Staff.dh_panel.find_by(email: params[:email])
          unless staff
            error!(failure_response_with_json('Staff not found for this email.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end

          unless staff.staffable_type == 'Distributor' && staff.staffable.active?
            error!(failure_response_with_json('Invalid.', HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          unless staff.valid_password?(params[:password])
            error!(failure_response_with_json('Invalid.', HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          response = {
            token: JsonWebToken.login_token_encode(staff),
            staff_name: staff.name,
            details: staff.staffable,
          }
          success_response_with_json('Successfully logged in.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nLogin failed due to: #{error.message}"
          error!(failure_response_with_json('Login failed.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Distributor logout.'
        delete '/sign_out' do
          bearer_token = request.headers.fetch('Authorization', '').split(' ').last
          if JsonWebToken.remove_token(bearer_token)
            success_response_with_json('Successfully logged out.', HTTP_CODE[:OK])
          else
            error!(failure_response_with_json('Logout failed.', HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nLogout failed due to: #{error.message}"
          error!(failure_response_with_json('Logout failed.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Get distributors reconciliation summary.'
        get '/balance' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
          date_range = start_date_time..end_date_time
          customer_orders = @current_distributor.customer_orders
          collected = customer_orders.joins(:payments).where(
            payments: { created_at: date_range, receiver_type: 'Staff' },
          ).sum('payments.currency_amount')

          collectable = customer_orders.joins(:payments).where(
            payments: { created_at: date_range, paymentable_type: %w(User Partner), receiver_type: %w(Rider Route) },
          ).sum('payments.currency_amount')

          return_customer_orders = @current_distributor.return_customer_orders.joins(:return_status_changes).where(
            return_status_changes: { created_at: date_range },
          ).includes(:return_status_changes)

          total_returned_request = return_customer_orders.where("return_status_changes.status = 'delivered_to_dh'")
          total_return_collectable = return_customer_orders.where("return_status_changes.status = 'in_transit'")
          response = {
            warehouse_cash_collected: collected,
            warehouse_collectable: collectable,
            total_returned_request: total_returned_request.count,
            total_return_collectable: total_return_collectable.count,
          }
          success_response_with_json('Successfully fetched reconciliation summary.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n\n#{__FILE__}\nUnable to fetch reconciliation summary due to #{error.message}"
          error!(failure_response_with_json('Unable to fetch reconciliation summary.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
