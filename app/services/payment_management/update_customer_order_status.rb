module PaymentManagement
  class UpdateCustomerOrderStatus
    include Interactor

    delegate :order_status, :order_delivered, to: :context

    def call
      return if order_status.update order_delivered

      context.fail!(error: order_status.errors.full_messages.to_sentence)
    end
  end
end
