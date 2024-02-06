module ShopothWarehouse
  module V1
    module Entities
      class ReconciledOrders < Grape::Entity
        expose :id
        expose :reconciled_date
        expose :amount
        expose :shipping_type
        expose :is_paid

        def reconciled_date
          payments&.last&.created_at
        end

        def amount
          payments.sum(:currency_amount)
        end

        def is_paid
          object.aggregated_transaction_customer_orders.customer_payment.present?
        end

        def payments
          @payments ||= object.payments.where(paymentable_type: %w(Route Rider), receiver_type: 'Staff')
        end

        def shipping_type
          object.shipping_type.titleize
        end
      end
    end
  end
end
