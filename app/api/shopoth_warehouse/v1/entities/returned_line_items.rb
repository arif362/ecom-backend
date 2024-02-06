module ShopothWarehouse
  module V1
    module Entities
      class ReturnedLineItems < Grape::Entity
        expose :id, as: :shopoth_line_item_id
        expose :quantity
        expose :total_price, as: :amount
        expose :sub_total
        expose :item

        def item
          {
            product_title: product&.title || '',
            sku: variant&.sku || '',
            unit_price: object.price,
            product_discount: object.discount_amount,
            product_attribute_values: variant&.product_attribute_values,
          }
        end

        def variant
          @variant ||= Variant.unscoped.find_by(id: object.variant_id)
        end

        def product
          @product ||= Product.unscoped.find_by(id: variant&.product_id, is_deleted: false)
        end
      end
    end
  end
end
