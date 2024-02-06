module Finance
  module V1
    module Entities
      class CustomerOrders < Grape::Entity
        expose :order_id
        expose :reconciled_date
        expose :amount
        expose :shipping_type

        def order_id
          object.frontend_id
        end

        def reconciled_date
          payments&.last&.created_at
        end

        def amount
          payments.sum(:currency_amount)
        end

        def payments
          @payments ||= object.payments.where("(payments.paymentable_type = 'Route' OR payments.paymentable_type = 'Rider') AND payments.receiver_type = 'Staff'")
        end
      end
    end
  end
end
