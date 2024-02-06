# frozen_string_literal: true

module ShopothCustomerCare
  module V1
    class Users < ShopothCustomerCare::Base
      helpers ShopothCustomerCare::V1::Serializers::CustomerOrderSerializer

      resource :users do
        desc 'Get user details by phone.'
        params do
          requires :phone, type: String
        end
        get '/phone' do
          user = User.find_by(phone: params[:phone])
          if user.present?
            present user, with: ShopothCustomerCare::V1::Entities::Users::UserDetailsByPhone
          else
            status :not_found
            { success: false, message: 'User not found with this phone number' }
          end
        rescue => error
          error!("Unable to return details due to #{error.message}")
        end

        desc 'get order list of specific customer'
        route_param :id do
          get '/orders' do
            user = User.find_by(id: params[:id])
            if user.present?
              ongoing_status_ids = OrderStatus.where.not(order_type: 'cancelled')
              user_orders = user.customer_orders.where(order_status_id: ongoing_status_ids.ids).order(created_at: :desc).last(10)
              if user_orders.present?
                get_customer_orders(user_orders)
              else
                status :not_found
                { success: false, message: 'Order not found' }
              end
            else
              status :not_found
              { success: false, message: 'Customer not found' }
            end
          rescue StandardError => error
            error!("Unable to fetch due to #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

      end
    end
  end
end
