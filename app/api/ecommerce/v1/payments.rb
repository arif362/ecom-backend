require 'net/http'

module Ecommerce
  module V1
    class Payments < Ecommerce::Base
      helpers do
        def order
          @order ||= @current_user.customer_orders.find_by!(id: params[:order_id], status: OrderStatus.getOrderStatus(OrderStatus.order_types[:order_placed]))
        end

        def payment
          @payment = Payment.find_by!(
            id: params['tran_id'],
            currency_amount: params['currency_amount'],
            currency_type: params['currency_type'],
          )
        end

        def cancel_order(customer_order)
         customer_order.payments.last.update!(status: Payment.statuses[:cancelled])
         customer_order.update!(order_status_id: OrderStatus.find_by(order_type: OrderStatus.order_types[:cancelled]).id,
                                         cancellation_reason: 'Payment transaction not valid',
                                         pay_status: CustomerOrder::pay_statuses[:payment_failed],
                                         changed_by: @current_user)

        end

        def cancel_payment(customer_order)
          customer_order.payments.last.update!(status: Payment.statuses[:cancelled])
        end
      end

      resources :payment do
        resources :cash_on_delivery do
          desc 'Initiate a payment through COD'
          params do
            requires :order_id, type: Integer
          end

          post '/initiate' do
            # payment_session = PaymentManagement::CashOnDelivery::InitiatePayment.call(
            #   order: order,
            #   order_status: order.status,
            #   form_of_payment: :cash,
            #   payment_status: :pending,
            #   customer: @current_user,
            # )
            #
            # if payment_session.success?
            success_response_with_json('successful', HTTP_CODE[:OK])
            # else
            #   # PaymentManagement::SendPaymentFailureEmail.call(order: order)
            #   error!(payment_session.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
            # end
          end

          desc 'Update the COD Payment as successful after delivery'
          params do
            requires :tran_id, type: String
            requires :currency_type, type: String
            requires :currency_amount, type: String
          end

          post '/finalize' do
            payment_session = PaymentManagement::CashOnDelivery::FinalizePayment.call(
              payment: payment,
              status: :successful,
              order_status: payment.customer_order.status,
              order_delivered: OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]),
            )

            if payment_session.success?
              success_response_with_json('successful', HTTP_CODE[:OK])
            else
              error!(failure_response_with_json(payment_session.error,
                                                HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        end

        resources :credit_card do
          desc 'Initiate a payment through Credit Card.'
          params do
            requires :order_id, type: Integer
          end

          post '/initiate' do
            Rails.logger.info "Initiating SSL Commerz Payment for Order: #{order.id} at #{DateTime.now.in_time_zone('Dhaka')}"
            payment_session = PaymentManagement::CreditCard::InitiatePayment.call(
              order: order,
              form_of_payment: :credit_card,
              payment_status: :pending,
              customer: @current_user,
              sub_domain: request.headers["Sub-Domain"],
            )

            if payment_session.success?
              data = { redirect_url: payment_session.gateway_page_url }
              success_response_with_json('Successfully initialized payment .', HTTP_CODE[:OK], data)
            else
              error!(failure_response_with_json(payment_session.error,
                                                HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end

          resources :ipn do
            desc 'GET: Listen to Instant Payment Notification(IPN) from SSLCOMMERZ'
            params do
              requires :status, type: String
              given status: ->(val) { val == 'valid' } do
                requires :val_id, type: String
              end
              requires :tran_id, type: String
              optional :risk_level
              requires :currency_type, type: String
              requires :currency_amount, type: String
            end

            route_setting :authentication, optional: true
            get do
              Rails.logger.info "IPN request params: #{params.inspect} at #{DateTime.now.in_time_zone('Dhaka')}"
              order = CustomerOrder.find(params['tran_id'].to_i)
              Rails.logger.info "GET: IPN request from SSLCommerz for Transaction: Order: #{order.id} at #{DateTime.now.in_time_zone('Dhaka')}"

              payment_by_ssl = order.payments.find_or_create_by!(
                currency_amount: params['currency_amount'],
                currency_type: params['currency_type'],
                form_of_payment: :credit_card,
                status: :pending,
                paymentable: order.customer,
              )

              request_validation = PaymentManagement::CreditCard::HandleIpnRequest.call(
                payment: payment_by_ssl,
                order: payment_by_ssl.customer_order,
                status: params['status'],
                val_id: params['val_id'],
                risk_level: params['risk_level'],
              )

              if request_validation.success? && payment_by_ssl.successful?
                payment_by_ssl.customer_order&.customer_paid!
                Rails.logger.info "IPN request successfully validated Transaction: #{order.id}"
              else
                # PaymentManagement::SendPaymentFailureEmail.call(order: payment.customer_order)
                cancel_order(payment_by_ssl.customer_order)
                Rails.logger.error "IPN request could not validate Transaction: #{order.id}"
              end
            end

            desc 'POST: Listen to Instant Payment Notification(IPN) from SSLCOMMERZ'
            params do
              requires :status, type: String
              given status: ->(val) { val == 'valid' } do
                requires :val_id, type: String
              end
              requires :tran_id, type: String
              optional :risk_level
              requires :currency_type, type: String
              requires :currency_amount, type: String
            end
            route_setting :authentication, optional: true

            post do
              Rails.logger.info "POST: IPN request params: #{params.inspect} at #{DateTime.now.in_time_zone('Dhaka')}"
              order = CustomerOrder.find(params['tran_id'].to_i)
              Rails.logger.info "GET: IPN request from SSLCommerz for Transaction: Order: #{order.id} at #{DateTime.now.in_time_zone('Dhaka')}"

              payment_by_ssl = order.payments.find_or_create_by!(
                currency_amount: params['currency_amount'],
                currency_type: params['currency_type'],
                form_of_payment: :credit_card,
                status: :pending,
                paymentable: order.customer,
                )

              request_validation = PaymentManagement::CreditCard::HandleIpnRequest.call(
                payment: payment_by_ssl,
                order: payment_by_ssl.customer_order,
                status: params['status'],
                val_id: params['val_id'],
                risk_level: params['risk_level'],
                )

              if request_validation.success? && payment_by_ssl.successful?
                payment_by_ssl.customer_order&.customer_paid!
                Rails.logger.info "IPN request successfully validated Transaction: #{order.id}"
              else
                # PaymentManagement::SendPaymentFailureEmail.call(order: payment.customer_order)
                cancel_order(payment_by_ssl.customer_order)
                Rails.logger.error "IPN request could not validate Transaction: #{order.id}"
              end

            end
          end
        end

        resources :wallet do
          desc 'Initiate a payment through Wallet'
          params do
            requires :order_id, type: Integer
          end

          post '/initiate' do
            payment_session = PaymentManagement::Wallet::InitiatePayment.call(
              order: order,
              order_status: order.status,
              form_of_payment: :wallet,
              payment_status: :pending,
              customer: @current_user,
            )

            if payment_session.success?
              order&.customer_paid!
              respond_with_json('successful', HTTP_CODE[:OK])
            else
              # PaymentManagement::SendPaymentFailureEmail.call(order: order)
              cancel_order(order)
              error!(payment_session.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end

          desc 'Update the Wallet Payment as successful after delivery'
          params do
            requires :tran_id, type: String
            requires :currency_type, type: String
            requires :currency_amount, type: String
          end

          post '/finalize' do
            payment_session = PaymentManagement::CashOnDelivery::FinalizePayment.call(
              payment: payment,
              status: :successful,
              order_status: payment.customer_order.status,
              order_delivered: OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]),
            )

            if payment_session.success?
              respond_with_json('successful', HTTP_CODE[:OK])
            else
              error!(
                payment_session.error,
                HTTP_CODE[:UNPROCESSABLE_ENTITY],
              )
            end
          end
        end

        resources :bkash do
          desc 'Create a payment through Bkash.'
          params do
            requires :order_id, type: Integer
          end

          post '/create' do
            payment_session = PaymentManagement::Bkash::CreatePayment.call(
              order: order,
              order_status: order.status,
              form_of_payment: :bkash,
              payment_status: :pending,
              customer: @current_user,
            )

            if payment_session.success?
              data = { payment_id: payment_session.payment_id, order_id: payment_session.order_id, bkash_response: payment_session.create_payment_bkash_response }
              success_response_with_json('Successfully created payment .', HTTP_CODE[:OK], data)
            else
              # PaymentManagement::SendPaymentFailureEmail.call(order: order)
              cancel_payment(order)
              error!(failure_response_with_json(payment_session.error, HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])

            end
          end

          desc 'Execute the bkash payment'
          params do
            requires :payment_id, type: String
            requires :order_id, type: String
          end

          post '/execute' do
            payment = order.payments.find_by!(status: :pending)
            payment_session = PaymentManagement::Bkash::ExecutePayment.call(
              payment_id: params[:payment_id],
              payment: payment,
            )

            if payment_session.success?
              payment&.customer_order&.customer_paid!
              data = { payment_id: payment_session.new_payment_id }
              success_response_with_json('Successfully executed payment .', HTTP_CODE[:OK], data)
            else
              cancel_order(payment.customer_order)
              error!(failure_response_with_json(payment_session.error,
                                                HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:UNPROCESSABLE_ENTITY])

            end
          end

          desc 'Cancel the bkash payment'
          params do
            requires :order_id, type: String
          end

          patch '/cancel' do
            payment = Payment.find_by!(customer_order_id: params[:order_id])
            cancel_order(payment.customer_order)
            success_response_with_json('Successfully cancelled payment .', HTTP_CODE[:OK], payment)

          rescue StandardError => e
            Rails.logger.error "\n#{__FILE__}\nPayment unable to cancel due to: #{e.message}"
            error!(failure_response_with_json('Payment unable to cancel.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        resources :nagad do
          desc 'Complete a payment through Nagad'
          params do
            requires :order_id, type: Integer
            requires :ip_address, type: String
          end

          post '/complete' do
            payment_session = PaymentManagement::Nagad::CompletePayment.call(
              order: order,
              ip_address: params[:ip_address],
              order_status: order.status,
              form_of_payment: :nagad,
              payment_status: :pending,
              customer: @current_user,
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

          desc 'Verify Nagad payment.'
          params do
            requires :order_id, type: Integer
            requires :ip_address, type: String
            requires :payment_reference_id
          end
          post '/verify' do
            Rails.logger.info "Nagad Verify params #{params}"
            order = @current_user.customer_orders.find(params[:order_id])
            payment_verification = PaymentManagement::Nagad::VerifyPayment.call(
              order: order,
              ip_address: params[:ip_address],
              payment_reference_id: params[:payment_reference_id],
            )
            if payment_verification.success?
              success_response_with_json('Successfully verified payment.', HTTP_CODE[:OK], { order_id: order.id })
            else
              error!(failure_response_with_json(payment_verification.error&.to_s,
                                                HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
            end
          rescue StandardError => error
            Rails.logger.info "Could not pay order #{params[:order_id]} with Nagad. Reason: #{error.full_message}"
            error!(failure_response_with_json("Could not pay order #{params[:order_id]} with Nagad. Reason: #{error.full_message}",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
