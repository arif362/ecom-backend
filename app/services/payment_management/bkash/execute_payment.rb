module PaymentManagement
  module Bkash
    class ExecutePayment
      include Interactor

      delegate :payment_id, :payment, :new_payment_id, :excute_payment_bkash_response, to: :context

      def call
        grant_token
        execute_payment
        query_payment
      end

      private

      def grant_token
        response = IO.popen("curl --request POST \
        --url #{grant_token_url} \
        --header 'Accept: application/json' \
        --header 'Content-Type: application/json' \
        --header 'password: #{ENV['BKASH_PASSWORD']}' \
        --header 'username: #{ENV['BKASH_USERNAME']}' \
        --data '{'app_key':'#{ENV['BKASH_APP_KEY']}','app_secret':'#{ENV['BKASH_APP_SECRET']}'}'").read

        response = JSON.parse(response, symbolize_names: true)
        context.id_token = response[:id_token]
      end

      def execute_payment
        response = IO.popen("curl --request POST \
        --url #{create_payment_url} \
        --header 'Accept: application/json' \
        --header 'Authorization: #{context.id_token}' \
        --header 'Content-Type: application/json' \
        --header 'X-APP-Key: #{ENV['BKASH_APP_KEY']}'").read

        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("Execute payment response for payment_id #{payment_id}: #{response}")
        search_transaction_details(response[:trxID])
        context.new_payment_id = response[:paymentID]
        context.new_payment_id.nil? ? context.fail!(error: response[:errorMessage]) : context.new_payment_id
      end

      def query_payment
        response = IO.popen("curl --request GET \
          --url #{query_payment_url} \
          --header 'Accept: application/json' \
          --header 'Authorization: #{context.id_token}' \
          --header 'Content-Type: application/json' \
          --header 'X-APP-Key: #{ENV['BKASH_APP_KEY']}'").read

        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("Query payment response for payment_id #{payment_id}: #{response}")
        payment.update(
          bkash_payment_id: response[:paymentID],
          bkash_transaction_status: response[:transactionStatus],
          status: Payment.map_bkash_to_pay_status(response[:transactionStatus]),
          created_at: response[:createTime].to_time,
          updated_at: response[:updateTime].to_time,
          payment_reference_id: response[:trxID],
        )
      end

      def search_transaction_details(trxID)
        response = IO.popen("curl --request GET \
          --url #{search_transaction_url(trxID)} \
          --header 'Accept: application/json' \
          --header 'Authorization: #{context.id_token}' \
          --header 'Content-Type: application/json' \
          --header 'X-APP-Key: #{ENV['BKASH_APP_KEY']}'").read

        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("Search transaction details response for payment_id #{payment_id}: #{response}")
      end

      def grant_token_url
        return 'https://checkout.pay.bka.sh/v1.2.0-beta/checkout/token/grant' if Rails.env.production?
        'https://checkout.sandbox.bka.sh/v1.2.0-beta/checkout/token/grant'
      end

      def create_payment_url
        return "https://checkout.pay.bka.sh/v1.2.0-beta/checkout/payment/execute/#{payment_id}" if Rails.env.production?
        "https://checkout.sandbox.bka.sh/v1.2.0-beta/checkout/payment/execute/#{payment_id}"
      end

      def query_payment_url
        return "https://checkout.pay.bka.sh/v1.2.0-beta/checkout/payment/query/#{payment_id}" if Rails.env.production?
        "https://checkout.sandbox.bka.sh/v1.2.0-beta/checkout/payment/query/#{payment_id}"
      end

      def search_transaction_url(trxID)
        return "https://checkout.pay.bka.sh/v1.2.0-beta/checkout/payment/search/#{trxID}" if Rails.env.production?
        "https://checkout.sandbox.bka.sh/v1.2.0-beta/checkout/payment/search/#{trxID}"
      end
    end
  end
end
