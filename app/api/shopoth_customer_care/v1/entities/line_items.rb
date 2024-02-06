module ShopothCustomerCare
  module V1
    module Entities
      class LineItems < Grape::Entity
        expose :id, as: :shopoth_line_item_id
        expose :quantity
        expose :total_price, as: :amount
        expose :sub_total
        expose :item
        expose :locations

        def locations
          wv_locations = variant&.warehouse_variants&.find_by(warehouse: warehouse)&.warehouse_variants_locations&.where('quantity > 0')
          wv_locations&.map do |wv_location|
            {
              id: wv_location.location_id,
              code: wv_location.location&.code,
              quantity: wv_location.quantity,
            }
          end&.compact&.uniq || []
        end

        def item
          {
            product_title: Product.unscoped.find_by(id: variant&.product_id, is_deleted: false)&.title || '',
            sku: variant&.sku || '',
            variant_id: object&.variant_id,
            unit_price: object.price,
            product_discount: object.discount_amount,
            product_attribute_values: variant&.product_attribute_values,
          }
        end

        def variant
          @variant ||= Variant.unscoped.find_by(id: object.variant_id)
        end

        def warehouse
          object.customer_order.warehouse
        end
      end
    end
  end
end
