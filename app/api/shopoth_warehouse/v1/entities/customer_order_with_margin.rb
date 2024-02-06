module ShopothWarehouse
  module V1
    module Entities
      class CustomerOrderWithMargin < Grape::Entity
        expose :id, as: :order_id
        expose :created_at, as: :order_at
        expose :completed_at, as: :delivery_date
        expose :order_type
        expose :pay_type
        expose :shipping_type
        expose :status
        expose :total_price, as: :price
        expose :partner_margin

        def partner_margin
          object.partner_margin&.margin_amount
        end

        def status
          object.status&.admin_order_status || ''
        end
      end
    end
  end
end
