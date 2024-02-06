module Finance
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
        expose :partner_code
        expose :partner_name
        expose :partner_commission
        expose :commission_sent

        def partner_code
          partner&.partner_code
        end

        def partner_name
          partner&.name
        end

        def partner_commission
          object&.partner_margin&.margin_amount&.round(2)
        end

        def commission_sent
          object&.aggregated_transaction_customer_orders&.where(transaction_type: :sub_agent_commission).present?
        end

        def partner
          @partner ||= object&.partner
        end

        def shipping_type
          object.shipping_type.titleize
        end
      end
    end
  end
end
