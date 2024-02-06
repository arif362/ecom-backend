module PaymentManagement
  module CashOnDelivery
    class InitiatePayment
      include Interactor::Organizer

      organize(
        PaymentManagement::CreatePaymentInstance,
      )
    end
  end
end
