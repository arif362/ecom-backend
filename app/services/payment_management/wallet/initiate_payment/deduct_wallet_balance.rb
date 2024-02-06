module PaymentManagement
  module Wallet
    class InitiatePayment
      class DeductWalletBalance
        include Interactor

        delegate :order, to: :context

        def call
          amount = order&.customer&.wallet&.currency_amount
          order.customer.wallet.update! currency_amount: amount - order.total_price
        end
      end
    end
  end
end
