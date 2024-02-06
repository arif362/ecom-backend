module ShopothWarehouse
  module V1
    module Entities
      class TransferOrderVariants < Grape::Entity
        expose :id
        expose :sku
        expose :code_by_supplier
        expose :product_id
        expose :product_title
        expose :price_distribution
        expose :product_attribute_values
        expose :locations do |variants, options|
          warehouse_variant = object.warehouse_variants.find_by(warehouse: options[:warehouse])
          warehouse_variant&.warehouse_variants_locations&.map do |warehouse_variants_location|
            {
              id: warehouse_variants_location.location_id,
              code: warehouse_variants_location.location&.code,
              quantity: warehouse_variants_location.quantity,
            }
          end&.compact&.uniq
        end

        def product_title
          Product.unscoped.find_by(id: object.product_id, is_deleted: false)&.title || ''
        end

        def product_attribute_values
          object.product_attribute_values.map do |attr_val|
            {
              value: attr_val.value,
            }
          end
        end
      end
    end
  end
end
