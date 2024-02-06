module PaymentManagement
  module CreditCard
    class HandleIpnRequest
      class CheckPaymentStatus
        include Interactor

        delegate :payment, :status, to: :context

        def call
          if payment.pending?
            Rails.logger.info 'Approaching to validate the payment in the next step'
          elsif payment.successful?
            Rails.logger.info "Payment is already successful for Transaction: #{payment.id}, requested twice?"
            context.fail!
          else
            Rails.logger.error "Invalid Transaction: #{payment.id}"
            context.fail!
          end
        end
      end
    end
  end
end
