module ShopothPartner
  module V1
    module Entities
      class OrderDetails < Grape::Entity
        expose :id, as: :order_id
        expose :created_at, as: :order_date
        expose :customer
        expose :order_type
        expose :order_status
        expose :shopoth_line_items, using: ShopothPartner::V1::Entities::OrdersLineItems
        expose :total_price
        expose :vat_shipping_charge
        expose :business_type

        def customer
          {
            name: object&.customer&.name,
            phone: object&.customer&.phone,
          }
        end

        def order_status
          object&.status&.order_type
        end

        def total_price
          {
            consumer_price: object.total_price,
          }
        end
      end
    end
  end
end
