module PaymentManagement
  class CreatePaymentInstance
    include Interactor

    delegate :order, :form_of_payment, :payment_status, :payment, :customer, to: :context
    CURRENCY_TYPE = 'BDT'.freeze

    def call
      context.payment = order.payments.build payment_attributes

      context.fail!(error: payment.errors.full_messages.to_sentence) unless payment.save
    end

    private

    def payment_attributes
      {
        currency_amount: order.total_price,
        currency_type: CURRENCY_TYPE,
        form_of_payment: form_of_payment,
        status: payment_status,
        paymentable: customer,
      }
    end
  end
end
