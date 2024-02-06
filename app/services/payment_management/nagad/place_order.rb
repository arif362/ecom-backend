module PaymentManagement
  module Nagad
    class PlaceOrder
      include Interactor

      delegate :order, :ip_address, :payment_reference_id, :challenge, to: :context

      def call
        url = URI("#{ENV['NAGAD_API_URL']}/api/dfs/check-out/complete/#{payment_reference_id}")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if ENV['NAGAD_API_URL'].start_with?('https')
        header = PaymentManagement::Nagad.headers(ip_address)
        request = Net::HTTP::Post.new(url, header)
        request.body = request_body.to_json

        response = http.request(request)
        response_body = JSON.parse(response.read_body, symbolize_names: true)
        Rails.logger.info "Nagad Place Order response for #{order.id}: #{response_body}"
        context.callback_url = response_body[:callBackUrl]
      end

      private

      def merchant_callback_url
        #TODO: This will be refactored in later
        return "#{ENV['ROOT_URL']}/nagad-verify" if Rails.env.production?
        return "#{ENV['ROOT_URL']}/nagad-verify" if Rails.env.pre_prod?
        return "#{ENV['ROOT_URL']}/nagad-verify" if Rails.env.staging?
        return "#{ENV['ROOT_URL']}/nagad-verify" if Rails.env.staging_v2?
         "#{ENV['ROOT_URL']}/nagad-verify"
      end

      def request_body
        {
          sensitiveData: sensitive_data,
          signature: signature,
          merchantCallbackURL: merchant_callback_url,
        }
      end

      def order_id
        @order_id ||= order.backend_id
      end

      def merchant_id
        @merchant_id ||= ENV['NAGAD_MERCHANT_ID']
      end

      def plain_sensitive_data
        {
          merchantId: merchant_id,
          orderId: order_id,
          currencyCode: '050',
          amount: order.total_price,
          challenge: challenge,
        }
      end

      def sensitive_data
        PaymentManagement::Nagad.encoded_sensitive_data(plain_sensitive_data.to_json)
      end

      def signature
        PaymentManagement::Nagad.signature(plain_sensitive_data.to_json)
      end
    end
  end
end
