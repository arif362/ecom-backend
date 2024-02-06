module ShopothPartner
  module V1
    module Entities
      class LineItems < Grape::Entity
        expose :id, as: :line_item_id
        expose :quantity
        expose :total_price, as: :price
        expose :item

        def item
          {
            product_title: object&.variant&.product&.title&.humanize,
            product_attribute_values: object&.variant&.product_attribute_values,
          }
        end
      end
    end
  end
end
