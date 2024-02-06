module ShopothWarehouse
  module V1
    module Entities
      class PackedVariants < Grape::Entity
        expose :id
        expose :sku
        expose :product_id
        expose :product_title
        expose :bundle_variants_count
        expose :bundle_locations
        expose :available_quantity

        def product_title
          Product.unscoped.find_by(id: object.product_id)&.title
        end

        def bundle_variants_count
          object.bundle.bundle_variants.count
        end

        def bundle_locations
          return [] if warehouse_variant.blank? || warehouse_variant.warehouse_variants_locations.where('quantity > 0').blank?

          warehouse_variant.warehouse_variants_locations.map do |warehouse_variant_location|
            {
              id: warehouse_variant_location.location_id,
              code: warehouse_variant_location.location&.code,
              quantity: warehouse_variant_location.quantity,
            }
          end&.uniq
        end

        def available_quantity
          warehouse_variant&.available_quantity || 0
        end

        def warehouse_variant
          @warehouse_variant ||= object.warehouse_variants&.find_by(warehouse: warehouse)
        end

        def warehouse
          @warehouse ||= options[:warehouse]
        end
      end
    end
  end
end
