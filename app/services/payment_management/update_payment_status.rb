module PaymentManagement
  class UpdatePaymentStatus
    include Interactor

    delegate :payment, :status, :payment_reference_id, to: :context

    def call
      context.fail!(error: payment.errors.full_messages.to_sentence) unless payment.update(status: status, payment_reference_id: context.payment_reference_id)
    end
  end
end
