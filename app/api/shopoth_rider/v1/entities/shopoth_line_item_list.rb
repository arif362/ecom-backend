module ShopothRider
  module V1
    module Entities
      class ShopothLineItemList < Grape::Entity
        expose :id, as: :shopoth_line_item_id
        expose :quantity
        expose :total_price, as: :amount
        expose :item

        def quantity
          object&.return_customer_orders.present? ? 1 : object&.quantity
        end

        def item
          value_array = object&.variant&.product_attribute_values.map { |attr| attr.value }
          {
            product_id: object&.variant&.product&.id,
            product_title: object&.variant&.product&.title,
            product_attribute_value: value_array.join(', '),
            consumer_price: object&.variant&.price_consumer,
          }
        end
      end
    end
  end
end
