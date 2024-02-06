module ShopothWarehouse
  module V1
    module Entities
      class ModifiedEnPartners < Grape::Entity
        expose :id
        expose :name
        expose :phone
        expose :due_payment

        def due_payment
          status = %w(delivered_to_partner completed)
          total_price = 0
          object.customer_orders&.each do |order|
            if status.include?(order.status&.order_type) && order.pay_status != 'partner_paid'
              paid_amount = order.payments&.where(status: :successful, paymentable: order.partner)&.sum(:currency_amount)
              total_price += order.total_price - paid_amount
            end
          end
          total_price.ceil
        end
      end
    end
  end
end

