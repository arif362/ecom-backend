module PaymentManagement
  module Wallet
    class FinalizePayment
      include Interactor::Organizer

      organize(
        PaymentManagement::UpdatePaymentStatus,
        PaymentManagement::UpdateCustomerOrderStatus,
      )
    end
  end
end
