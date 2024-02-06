module PaymentManagement
  module Wallet
    class InitiatePayment
      include Interactor::Organizer

      organize(
        PaymentManagement::Wallet::InitiatePayment::CheckWalletBalance,
        PaymentManagement::CreatePaymentInstance,
        PaymentManagement::Wallet::InitiatePayment::DeductWalletBalance,
      )
    end
  end
end
