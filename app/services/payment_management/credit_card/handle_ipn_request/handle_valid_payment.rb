require 'net/http'

module PaymentManagement
  module CreditCard
    class HandleIpnRequest
      class HandleValidPayment
        include Interactor

        delegate :payment, :val_id, to: :context

        VALID_STATUSES = %w(VALID VALIDATED).freeze

        def call
          url = URI.parse(order_validation_url)
          url.query = URI.encode_www_form(params.stringify_keys)
          response = Net::HTTP.get_response(url)
          response_body = JSON.parse response.body
          status = response_body['status']

          if VALID_STATUSES.include? status
            handle_valid_status response_body
          else
            log = "Payment validation failed for Transaction: #{payment.id}"
            payment_status = :failed
            log_and_update_payment_status(log, payment_status)
            context.fail!
          end
        end

        def handle_valid_status(response_body)
          if payment_matches? response_body
            log = "Payment successful for Transaction: #{payment.id}"
            payment_status = :successful
            log_and_update_payment_status(log, payment_status, response_body['bank_tran_id'])
            Rails.logger.info "Updating customer paid for online payment_id: #{payment.id}"
            payment&.customer_order&.customer_paid!
          else
            log = "Payment tempered for Transaction: #{payment.id}"
            payment_status = :tempered
            log_and_update_payment_status(log, payment_status)
            context.fail!
          end
        end

        def payment_matches?(response_body)
          payment_from_response = Payment.find_by!(
            customer_order_id: response_body['tran_id'],
            currency_amount: response_body['currency_amount'],
            currency_type: response_body['currency_type'],
          )

          payment == payment_from_response
        end

        private

        def order_validation_url
          return 'https://securepay.sslcommerz.com/validator/api/validationserverAPI.php' if Rails.env.production?

          'https://sandbox.sslcommerz.com/validator/api/validationserverAPI.php'
        end

        def params
          # TODO: Rails.application.credentials.dig(:ssl_commerz, :store_id) not working
          {
            val_id: val_id,
            store_id: ENV['SSL_COMMERZ_STORE_ID'],
            store_passwd: ENV['SSL_COMMERZ_STORE_PASSWORD'],
          }
        end

        def log_and_update_payment_status(log, status, payment_reference_id = '')
          Rails.logger.info log
          PaymentManagement::UpdatePaymentStatus.call(payment: payment, status: status, payment_reference_id: payment_reference_id)
        end
      end
    end
  end
end
