module PaymentManagement
  module CreditCard
    class HandleIpnRequest
      class ValidatePayment
        include Interactor

        VALID_STATUS = 'VALID'.freeze

        delegate :order, :payment, :status, :val_id, :risk_level, to: :context

        def call
          if status == VALID_STATUS && risk_level == '1'
            Rails.logger.error "Payment risky for Transaction #{payment.id}"
            PaymentManagement::UpdatePaymentStatus.call(payment: payment, status: :risky)

          elsif status == VALID_STATUS
            PaymentManagement::CreditCard::HandleIpnRequest::HandleValidPayment.call(
              order: order,
              payment: payment,
              val_id: val_id,
              risk_level: risk_level,
            )
          else
            PaymentManagement::CreditCard::HandleIpnRequest::HandleInvalidPayment.call(
              order: order,
              payment: payment,
              status: status,
            )
          end
        end
      end
    end
  end
end
