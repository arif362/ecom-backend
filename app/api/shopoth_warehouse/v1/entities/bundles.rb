module ShopothWarehouse
  module V1
    module Entities
      class Bundles < Grape::Entity
        expose :id
        expose :sku
        expose :code_by_supplier
        expose :product_id
        expose :product_title
        expose :price_distribution
        expose :product_attribute_values
        expose :suppliers_variants
        expose :bundle_locations
        expose :bundle_variants
        expose :editable
        expose :bundle_available_quantity

        def bundle_locations
          warehouse_variant = object.warehouse_variants.find_by(warehouse: warehouse)
          return [] if warehouse_variant.blank?
          locations = warehouse_variant.warehouse_variants_locations&.where('quantity > 0')
          return [] if warehouse_variant.blank?
          locations&.map do |wvl|
            {
              id: wvl.location_id,
              code: wvl.location&.code,
              quantity: wvl.quantity,
            }
          end&.uniq
        end

        def bundle_variants
          object.bundle&.bundle_variants&.includes(variant: :product)&.map do |bundle_variant|
            variant = bundle_variant.variant
            {
              variant_id: bundle_variant.variant_id,
              sku: variant.sku,
              product_title: Product.unscoped.find_by(id: variant.product_id)&.title,
              quantity: bundle_variant.quantity,
              warehouse_available_quantity: variant.warehouse_variant(warehouse)&.available_quantity,
              locations: locations(variant.warehouse_variant(warehouse)),
            }
          end&.uniq
        end

        def product_attribute_values
          object.product_attribute_values&.map do |attr_val|
            {
              value: attr_val.value,
            }
          end&.uniq
        end

        def suppliers_variants
          supplier_variants = object.suppliers_variants.select { |sv| sv.supplier.present? }
          return [] unless supplier_variants.present?

          supplier_variants.map do |supplier_variant|
            {
              id: supplier_variant.id,
              variant_id: supplier_variant.variant_id,
              supplier_id: supplier_variant.supplier_id,
              supplier_name: supplier_variant.supplier&.supplier_name,
              supplier_price: supplier_variant.supplier_price,
            }
          end&.uniq
        end

        def product_title
          object&.product&.title
        end

        def locations(warehouse_variant)
          return [] if warehouse_variant.blank? || warehouse_variant.warehouse_variants_locations.where('quantity > 0').blank?

          warehouse_variant.warehouse_variants_locations&.map do |warehouse_variant_location|
            {
              id: warehouse_variant_location.location_id,
              code: warehouse_variant_location.location&.code,
              quantity: warehouse_variant_location.quantity,
            }
          end&.uniq
        end

        def editable
          object.bundle&.is_editable || false
        end

        def warehouse
          @warehouse ||= options[:warehouse]
        end

        def bundle_available_quantity
          warehouse.warehouse_variants.find_by(variant_id: object.id)&.available_quantity || 0
        end
      end
    end
  end
end
