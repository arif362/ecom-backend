module PaymentManagement
  module CreditCard
    class HandleIpnRequest
      include Interactor::Organizer

      organize(
        PaymentManagement::CreditCard::HandleIpnRequest::CheckPaymentStatus,
        PaymentManagement::CreditCard::HandleIpnRequest::ValidatePayment,
      )
    end
  end
end
