module PaymentManagement
  module Bkash
    class CreatePayment
      include Interactor

      delegate :order, :form_of_payment, :payment_status, :customer, to: :context

      def call
        create_payment_instance if order.payments.empty?
        grant_token
        create_payment
      end

      private

      def create_payment_instance
        PaymentManagement::CreatePaymentInstance.call(
          order: order,
          form_of_payment: form_of_payment,
          payment_status: payment_status,
          customer: customer,
        )
      end

      def grant_token
        response = IO.popen("curl --request POST \
        --url #{grant_token_url} \
        --header 'Accept: application/json' \
        --header 'Content-Type: application/json' \
        --header 'password: #{ENV['BKASH_PASSWORD']}' \
        --header 'username: #{ENV['BKASH_USERNAME']}' \
        --data '{'app_key':'#{ENV['BKASH_APP_KEY']}','app_secret':'#{ENV['BKASH_APP_SECRET']}'}'").read

        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info "Response from bkash #{response}"
        context.id_token = response[:id_token]
        context.bkash_grant_token_response = response
      end

      def create_payment
        response = IO.popen("curl --request POST \
        --url #{create_payment_url} \
        --header 'Accept: application/json' \
        --header 'Authorization: #{context.id_token}' \
        --header 'Content-Type: application/json' \
        --header 'X-APP-Key: #{ENV['BKASH_APP_KEY']}' \
        --data '{'amount':'#{amount}','currency':'BDT','intent':'sale','merchantInvoiceNumber':'#{order.id}'}'").read

        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("Create payment response for order_id #{order.id}: #{response}")
        context.payment_id = response[:paymentID]
        context.order_id = response[:merchantInvoiceNumber]
        context.create_payment_bkash_response = response
      end

      def grant_token_url
        return 'https://checkout.pay.bka.sh/v1.2.0-beta/checkout/token/grant' if Rails.env.production?

        'https://checkout.sandbox.bka.sh/v1.2.0-beta/checkout/token/grant'
      end

      def create_payment_url
        return 'https://checkout.pay.bka.sh/v1.2.0-beta/checkout/payment/create' if Rails.env.production?

        'https://checkout.sandbox.bka.sh/v1.2.0-beta/checkout/payment/create'
      end

      def amount
        order.total_price
      end
    end
  end
end
