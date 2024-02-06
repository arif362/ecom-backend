module PaymentManagement
  module Nagad
    class VerifyPayment
      include Interactor

      delegate :order, :ip_address, :payment_reference_id, to: :context

      def call
        url = URI("#{ENV['NAGAD_API_URL']}/api/dfs/verify/payment/#{payment_reference_id}")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if ENV['NAGAD_API_URL'].start_with?('https')
        header = PaymentManagement::Nagad.headers(ip_address)
        request = Net::HTTP::Get.new(url, header)
        response = http.request(request)
        response_body = JSON.parse(response.read_body, symbolize_names: true)
        Rails.logger.info "Verifying Nagad payment #{payment_reference_id}  for order id #{order.id}, response: #{response_body}"
        if response_body[:status] == 'Success'
          order.update_columns(is_customer_paid: true)
          payment = order.payments.where(paymentable: order.customer, form_of_payment: :nagad).last
          # As per requirements payment_reference_id(common place) need to save for all online payment.
          payment.update(status: :successful, nagad_payment_reference_id: response_body[:issuerPaymentRefNo], payment_reference_id: response_body[:issuerPaymentRefNo])
          Rails.logger.info "Customer order successfully paid order: #{order.id}"
          context.redirect_url = success_url
        else
          Rails.logger.info "Customer order failed for Nagad payment: #{order.id} and payment_reference_id: #{payment_reference_id}"
          order.update!(order_status_id: OrderStatus.find_by(order_type: OrderStatus.order_types[:cancelled]).id,
                        cancellation_reason: 'Nagad Payment transaction failed',
                        pay_status: CustomerOrder::pay_statuses[:payment_failed],
                        changed_by: @current_user)
          context.fail!(error: "Payment isn't successful.")
        end
      end

      def success_url
        #TODO: This will be refactored in later

        return "#{ENV['ROOT_URL']}/order-success?shipping_type=#{order.shipping_type}" if Rails.env.production?
        return "#{ENV['ROOT_URL']}/order-success?shipping_type=#{order.shipping_type}" if Rails.env.pre_prod?
        return "#{ENV['ROOT_URL']}/order-success?shipping_type=#{order.shipping_type}" if Rails.env.staging?
        return "#{ENV['ROOT_URL']}/order-success?shipping_type=#{order.shipping_type}" if Rails.env.staging_v2?
        "#{ENV['ROOT_URL']}/order-success?shipping_type=#{order.shipping_type}"
      end

      def failure_url
        #TODO: This will be refactored in later
        return "#{ENV['ROOT_URL']}/order-failure" if Rails.env.production?
        return "#{ENV['ROOT_URL']}/order-failure" if Rails.env.pre_prod?
        return "#{ENV['ROOT_URL']}/order-failure" if Rails.env.staging?
        return "#{ENV['ROOT_URL']}/order-failure" if Rails.env.staging_v2?

        "http://localhost:3000/order-failure"
      end
    end
  end
end
