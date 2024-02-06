module ShopothWarehouse
  module V1
    module Entities
      class PartnerMargin < Grape::Entity
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
        expose :partner_id
        expose :partner_name
        expose :partner_commission
        expose :commission_sent
        expose :created_by

        def partner_id
          object&.partner_id
        end

        def partner_name
          object&.partner&.name
        end

        def partner_commission
          object&.partner_margin&.margin_amount
        end

        def commission_sent
          object&.aggregated_transaction_customer_orders.where(transaction_type: :agent_commission).present?
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
