module ShopothWarehouse
  module V1
    module Entities
      class Variants < Grape::Entity
        include ShopothWarehouse::V1::Helpers::ImageHelper

        expose :id
        expose :sku
        expose :weight
        expose :height
        expose :width
        expose :depth
        expose :deleted_at
        expose :product_id
        expose :configuration
        expose :is_deleted
        expose :primary
        expose :price_distribution
        expose :price_retailer
        expose :price_consumer
        expose :sku_case_dimension
        expose :case_weight
        expose :price_agami_trade
        expose :discount_type
        expose :consumer_discount
        expose :vat_tax
        expose :effective_mrp
        expose :moq
        expose :sku_case_width
        expose :sku_case_length
        expose :sku_case_height
        expose :weight_unit
        expose :height_unit
        expose :width_unit
        expose :depth_unit
        expose :sku_case_width_unit
        expose :sku_case_length_unit
        expose :sku_case_height_unit
        expose :case_weight_unit
        expose :code_by_supplier
        expose :is_deleted
        expose :bundle_status
        expose :b2b_price
        expose :b2b_discount_type
        expose :b2b_discount
        expose :b2b_effective_mrp
        expose :created_by

        expose :product_attribute_values do |variant, _options|
          ShopothWarehouse::V1::Entities::ProductAttributeValues.represent(variant.product_attribute_values)
        end
        expose :locations

        def product_attribute_images(attribute_images, val)
          attribute_images.map do |image|
            process_prod_attr_val(val).merge(prepare_hash(image, val))
          end
        end

        def prepare_hash(image, val)
          {
            images: {
              id: image&.id,
              urls: image_paths(image.images),
            },
            product_attribute: product_attribute(val)
          }
        end

        def product_attribute(val)
          attribute = val.product_attribute
          {
            id: attribute&.id,
            name: attribute&.name,
            bn_name: attribute&.bn_name,
          }
        end

        def process_prod_attr_val(attr_val)
          {
            id: attr_val&.id,
            product_attribute_id: attr_val&.product_attribute_id,
            value: attr_val&.value,
            bn_value: attr_val&.bn_value,
            is_deleted: attr_val&.is_deleted,
          }
        end

        def locations
          warehouse_variant_locations = object.warehouse_variants_locations.where('warehouse_id = ? AND quantity > 0', options[:warehouse].id).distinct
          return [] if warehouse_variant_locations.empty?

          warehouse_variant_locations.map do |wv_location|
            {
              code: wv_location&.location&.code || '',
              quantity: wv_location.quantity,
            }
          end.compact
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
