module PaymentManagement
  module CreditCard
    class InitiatePayment
      include Interactor::Organizer

      organize(
        PaymentManagement::CreatePaymentInstance,
        PaymentManagement::CreditCard::InitiatePayment::PreparePaymentParams,
        PaymentManagement::CreditCard::InitiatePayment::CreateSession,
      )
    end
  end
end
