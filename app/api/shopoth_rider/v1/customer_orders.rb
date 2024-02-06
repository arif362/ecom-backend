module ShopothRider
  module V1
    class CustomerOrders < ShopothRider::Base
      resource :customer_orders do
        desc 'Show Details of One Order for rider'
        route_param :id do
          get 'details' do
            order = CustomerOrder.find(params[:id])
            present order, with: ShopothRider::V1::Entities::CustomerOrderDetails
          rescue StandardError => error
            error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Get PIN code of CustomerOrder for rider'
        route_param :id do
          get 'pin' do
            order = CustomerOrder.find(params[:id])
            status :ok
            { success: true, pin: order.pin }
          rescue StandardError => error
            error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Resend PIN code to customer'
        post 'resend_pin' do
          params do
            requires :order_id, type: Integer
          end
          order = CustomerOrder.find(params[:order_id])
          message = "Your Order PIN is #{order.pin}, please share this PIN with the Rider."
          send_pin = SmsManagement::SendMessage.call(phone: order.customer&.phone, message: message)

          if send_pin.success?
            status :ok
            respond_with_json('PIN sent successfully', HTTP_CODE[:OK])
          else
            status :unprocessable_entity
            error!(send_pin.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
