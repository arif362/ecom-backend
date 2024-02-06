module PaymentManagement
  module Wallet
    class InitiatePayment
      class CheckWalletBalance
        include Interactor

        delegate :order, to: :context

        def call
          wallet_amount = order&.customer&.wallet&.currency_amount
          return unless order.total_price > wallet_amount

          context.fail!(error: 'Insufficient Wallet Balance')
        end
      end
    end
  end
end
