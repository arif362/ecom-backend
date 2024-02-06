# frozen_string_literal: true

module ShopothCustomerCare
  module V1
    class UserModificationRequests < ShopothCustomerCare::Base
      resource :account_requests do
        desc 'User Request List'
        params do
          use :pagination, per_page: 25
          optional :phone, type: String
          optional :status, type: String
        end
        get do
          user_modification_requests = UserModificationRequest.all.order(id: :desc)
          user_modification_requests = user_modification_requests.where(status: params[:status]) if params[:status].present?
          user_modification_requests = user_modification_requests.joins(:user).where('users.phone = ?', params[:phone]) if params[:phone].present?
          user_modification_requests = paginate(Kaminari.paginate_array(user_modification_requests))
          success_response_with_json('Successfully Fetch User Request List', HTTP_CODE[:OK],
                                     ShopothCustomerCare::V1::Entities::UserModificationRequests.represent(user_modification_requests))
        rescue StandardError => error
          Rails.logger.info "user request fetch error #{error.message}"
          error!(failure_response_with_json('Failed to fetch list', HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end


        desc 'User Request Details'
        route_param :id do
          get do
            user_modification_request = UserModificationRequest.find(params[:id])
            success_response_with_json('Successfully Fetch User Request Details', HTTP_CODE[:OK],
                                       ShopothCustomerCare::V1::Entities::UserModificationRequests.represent(user_modification_request))
          rescue StandardError => error
            Rails.logger.info "user request details error #{error.message}"
            error!(failure_response_with_json('Failed to fetch details', HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end
        end


        desc 'Create Account Modification Request'
        params do
          requires :user_id, type: Integer
          requires :request_type, type: String, values: UserModificationRequest.request_types.keys
          requires :user_modify_reason_id, type: Integer
          optional :reason, type: String
        end
        post do
          user_modification_request = UserModificationRequest.create_by_customer_care(declared(params))
          success_response_with_json('Successfully make modification', HTTP_CODE[:OK],
                                     ShopothCustomerCare::V1::Entities::UserModificationRequests.represent(user_modification_request))
        rescue StandardError => error
          Rails.logger.info "create request error #{error.message}"
          error!(failure_response_with_json('Failed to make request', HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end


        desc 'Approve User Request'
        route_param :id do
          put :approve do
            user_modification_request = UserModificationRequest.find(params[:id])
            user_modification_request.approved!
            success_response_with_json('Successfully Approved the Request', HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.info "Request approval error #{error.message}"
            error!(failure_response_with_json("Failed to approved request due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end
        end


        desc 'Reject User Request'
        route_param :id do
          put :reject do
            user_modification_request = UserModificationRequest.find(params[:id])
            user_modification_request.rejected!
            success_response_with_json('Successfully Rejected the Request', HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.info "Request approval error #{error.message}"
            error!(failure_response_with_json("Failed to rejected request due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
