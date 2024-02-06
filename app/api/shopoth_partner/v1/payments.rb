module ShopothPartner
  module V1
    class Payments < ShopothPartner::Base
      helpers do
        def order
          @order ||= @current_partner.customer_orders.find_by!(id: params[:order_id],
                                                               status: OrderStatus.getOrderStatus(OrderStatus.order_types[:order_placed]))
        end
        def cancel_order(customer_order)
          customer_order.payments.last.update!(status: Payment.statuses[:cancelled])
          customer_order.update!(order_status_id: OrderStatus.find_by(order_type: OrderStatus.order_types[:cancelled]).id,
                                 cancellation_reason: 'Payment transaction not valid',
                                 pay_status: CustomerOrder.pay_statuses[:payment_failed],
                                 changed_by: @current_partner)

        end
      end
      resources :payment do
        desc 'Complete a payment through Nagad'
        params do
          requires :order_id, type: Integer
          requires :ip_address, type: String
        end

        post 'nagad/complete' do
          payment_session = PaymentManagement::Nagad::CompletePayment.call(
            order: order,
            ip_address: params[:ip_address],
            order_status: order.status,
            form_of_payment: :nagad,
            payment_status: :pending,
            customer: @current_partner,
          )
          if payment_session.success?
            puts payment_session.callback_url
            data = { redirect_url: payment_session.callback_url }
            success_response_with_json('Successfully completed payment .', HTTP_CODE[:OK], data)

          else
            cancel_order(order)
            error!(failure_response_with_json(payment_session.error,
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
