module PaymentManagement
  module CreditCard
    class HandleIpnRequest
      class HandleInvalidPayment
        include Interactor

        delegate :order, :payment, :status, to: :context

        INVALID_PAYMENT_STATUS = {
          failed: 'FAILED',
          cancelled: 'CANCELLED',
          unattempted: 'UNATTEMPTED',
          expired: 'EXPIRED',
        }.freeze

        def call
          if status == INVALID_PAYMENT_STATUS[:failed]
            log = "Transaction declined by customer's Issuer Bank for Transaction: #{payment.id}"
            update_order_as_cancelled
            log_and_update_invalid_payment_status(log, status)
          elsif status == INVALID_PAYMENT_STATUS[:cancelled]
            log = "Transaction cancelled by customer for Transaction: #{payment.id}"
            update_order_as_cancelled
            log_and_update_invalid_payment_status(log, status)
          elsif status == INVALID_PAYMENT_STATUS[:unattempted]
            log = "Customer did not choose to pay any channel for Transaction: #{payment.id}"
            log_and_update_invalid_payment_status(log, status)
          elsif status == INVALID_PAYMENT_STATUS[:expired]
            log = "Transaction Timeout for Transaction: #{payment.id}"
            log_and_update_invalid_payment_status(log, status)
          else
            log = "Do not know how to handle status: #{status} for Transaction: #{payment.id}"
            log_and_update_invalid_payment_status(log)
          end
        end

        def log_and_update_invalid_payment_status(log, status = nil)
          Rails.logger.error log
          PaymentManagement::UpdatePaymentStatus.call(payment: payment, status: status.downcase) if status
          context.fail!
        end

        def update_order_as_cancelled
          cancelled_status_id = OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled])&.id
          order.update order_status_id: cancelled_status_id
        end
      end
    end
  end
end
