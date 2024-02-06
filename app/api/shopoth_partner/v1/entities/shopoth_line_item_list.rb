module ShopothPartner
  module V1
    module Entities
      class ShopothLineItemList < Grape::Entity
        expose :id, as: :shopoth_line_item_id
        expose :quantity
        expose :sub_total, as: :amount
        expose :item

        def quantity
          object&.quantity
        end

        def sub_total
          object&.return_customer_orders.present? ? object.sub_total / object.quantity : object.sub_total
        end

        def item
          value_array = object&.variant&.product_attribute_values&.map { |attr| attr.value }
          product_title = I18n.locale == :bn ? object&.variant&.product&.bn_title : object&.variant&.product&.title
          {
            product_id: object&.variant&.product&.id,
            product_title: product_title,
            product_attribute_value: value_array&.join(', '),
            consumer_price: object.sub_total / object.quantity,
          }
        end
      end
    end
  end
end
