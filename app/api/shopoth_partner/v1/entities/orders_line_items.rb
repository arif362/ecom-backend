module ShopothPartner
  module V1
    module Entities
      class OrdersLineItems < Grape::Entity
        expose :id, as: :line_item_id
        expose :item
        expose :quantity
        expose :price

        def item
          {
            product_title: object&.variant&.product&.title&.humanize,
            product_attribute_values: object&.variant&.product_attribute_values,
          }
        end

        def price
          if object.variant.present?
            {
              retailer_price: (object&.variant&.price_retailer.to_d * object.quantity.to_d).abs,
              consumer_price: object.sub_total,
              partner_margin: ((object&.variant&.price_consumer.to_d * object.quantity.to_d) -
                (object&.variant&.price_retailer.to_d * object.quantity.to_d)).abs,
            }
          else
            {}
          end
        end
      end
    end
  end
end
