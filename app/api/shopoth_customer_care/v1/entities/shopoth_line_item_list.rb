module ShopothCustomerCare
  module V1
    module Entities
      class ShopothLineItemList < Grape::Entity
        expose :id, as: :shopoth_line_item_id
        expose :quantity
        expose :total_price, as: :amount
        expose :item
        expose :sub_total
        expose :effective_mrp

        def item
          {
            product_title: Product.unscoped.find_by(id: variant&.product_id, is_deleted: false)&.title || '',
            sku: variant&.sku || '',
            unit_price: object.price,
            product_discount: object.discount_amount,
            product_attribute_values: product_attribute_values(variant),
          }
        end

        def product_attribute_values(variant)
          pro_attr_values = []
          if variant.present? && variant.product_attribute_values.present?
            variant.product_attribute_values.each do |at|
              pro_attr_values << {
                id: at.id,
                product_attribute_id: at.product_attribute_id,
                name: at.product_attribute&.name,
                value: at.value,
                bn_name: at.product_attribute&.bn_name,
                bn_value: at.bn_value,
                created_at: at.created_at,
                updated_at: at.updated_at,
                is_deleted: at.is_deleted,
              }
            end
          end
          pro_attr_values
        end

        def variant
          @variant ||= Variant.unscoped.find_by(id: object.variant_id)
        end

        def effective_mrp
          object.effective_unit_price
        end
      end
    end
  end
end
