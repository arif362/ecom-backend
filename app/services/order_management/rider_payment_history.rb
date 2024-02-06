module OrderManagement
  class RiderPaymentHistory
    include Interactor

    delegate :orders,
             :payment_history,
             to: :context

    def call
      context.payment_history = fetch_payment_history
    end

    def fetch_payment_history
      context.orders.select do |order|
        order.pay_type == 'cash_on_delivery' && order.status.order_type == 'completed'
      end
    end
  end
end