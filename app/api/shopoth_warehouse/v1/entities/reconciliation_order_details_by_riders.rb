module ShopothWarehouse
  module V1
    module Entities
      class ReconciliationOrderDetailsByRiders < Grape::Entity
        expose :id
        expose :completed_at, as: :delivery_date
        expose :created_at, as: :order_date
        expose :total_amount
        expose :collected_by_rider
        expose :collected_by_dh
        expose :payment_type

        def total_amount
          object.total_price
        end

        def collected_by_rider
          object.payments.where(paymentable_type: 'User', receiver_type: 'Rider').sum(:currency_amount)
        end

        def collected_by_dh
          object.payments.where(paymentable_type: 'Rider', receiver_type: 'Staff').sum(:currency_amount)
        end

        def payment_type
          pay_type = 'Online Payment'
          pay_type = 'Cash On Delivery' if object.cash_on_delivery?
          pay_type
        end
      end
    end
  end
end
