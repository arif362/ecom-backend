module ShopothPartner
  module V1
    module Entities
      class BnOrdersLineItems < Grape::Entity
        expose :id, as: :line_item_id
        expose :item
        expose :quantity
        expose :price

        def item
          {
            product_title: object&.variant&.product&.bn_title,
            product_attribute_values: product_attribute_values,
          }
        end

        def price
          if object.variant.present?
            {
              retailer_price: (object&.variant&.price_retailer.to_d * object.quantity.to_d).abs.to_s.to_bn,
              consumer_price: object.sub_total.to_s.to_bn,
              partner_margin: ((object&.variant&.price_consumer.to_d * object.quantity.to_d) -
                (object&.variant&.price_retailer.to_d * object.quantity.to_d)).abs.to_s.to_bn,
            }
          else
            {}
          end
        end

        def quantity
          object.quantity.to_s.to_bn
        end

        def product_attribute_values
          object&.variant&.product_attribute_values&.map do |val|
            {
              'id': val.id,
              'product_attribute_id': val.product_attribute_id,
              'value': val.bn_value,
            }
          end || []
        end
      end
    end
  end
end
