module ShopothWarehouse
  module V1
    module Entities
      class AggregatedTransactionPartnerMargin < Grape::Entity
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

        def partner_name
          object.partner&.name || ''
        end

        def partner_commission
          object.partner_margin&.margin_amount&.round(2) || 0
        end

        def shipping_type
          object.shipping_type.titleize
        end
      end
    end
  end
end
