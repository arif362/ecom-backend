require 'net/http'

module PaymentManagement
  module CreditCard
    class InitiatePayment
      class CreateSession
        include Interactor

        delegate :params, :gateway_page_url, to: :context

        def call
          url = URI.parse(request_session_url)
          response = Net::HTTP.post_form(url, params.stringify_keys)
          response_body = JSON.parse response.body

          if response_body['status'] == 'SUCCESS'
            context.gateway_page_url =  response_body['GatewayPageURL']
          else
            failed_reason = response_body['failedreason']
            Rails.logger.error "Session creation failed because #{failed_reason}"
            context.fail!(error: failed_reason)
          end
        end

        private

        def request_session_url
          return 'https://securepay.sslcommerz.com/gwprocess/v4/api.php' if Rails.env.production?

          'https://sandbox.sslcommerz.com/gwprocess/v4/api.php'
        end
      end
    end
  end
end
