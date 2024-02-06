module PaymentManagement
  module CashOnDelivery
    class FinalizePayment
      include Interactor::Organizer

      organize(
        PaymentManagement::UpdatePaymentStatus,
        PaymentManagement::UpdateCustomerOrderStatus,
      )
    end
  end
end
