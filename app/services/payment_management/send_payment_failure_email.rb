module PaymentManagement
  class SendPaymentFailureEmail
    include Interactor

    delegate :order, to: :context

    def call
      PaymentMailer.failure(order).deliver_now
    end
  end
end
