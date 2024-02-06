module ShopothWarehouse
  module V1
    module Entities
      class AggregatedTransactionAgentCommission < Grape::Entity
        expose :id, as: :order_id
        expose :created_at
        expose :completed_at
        expose :order_type
        expose :shipping_type
        expose :name, as: :customer_name
        expose :phone
        expose :cart_total_price, as: :price_before_discount
        expose :total_discount_amount, as: :discount_amount
        expose :total_price, as: :price_after_discount
        expose :agent_commission

        def agent_commission
          object.distributor_margin&.amount&.round(2) || 0
        end
      end
    end
  end
end
