module PaymentManagement
  class SendPaymentConfirmationEmail
    include Interactor

    delegate :order, to: :context

    def call
      PaymentMailer.successful(order).deliver_now
    end
  end
end
