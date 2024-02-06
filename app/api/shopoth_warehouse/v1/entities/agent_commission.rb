module ShopothWarehouse
  module V1
    module Entities
      class AgentCommission < Grape::Entity
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
        expose :commission_sent

        def agent_commission
          object&.total_price * (1.5 / 100)
        end

        def commission_sent
          object&.aggregated_transaction_customer_orders.where(transaction_type: :agent_commission).present?
        end
      end
    end
  end
end
