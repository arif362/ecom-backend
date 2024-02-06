module ShopothWarehouse
  module V1
    module Entities
      module LineItems
        class ItemWithLocations < Grape::Entity
          expose :id
          expose :variant_id
          expose :product_id
          expose :product_title
          expose :received_quantity
          expose :qc_passed
          expose :qc_failed, as: :quality_failed
          expose :quantity_failed
          expose :qc_status
          # expose :qr_code_initials
          # expose :qr_code_variant_quantity_start
          # expose :qr_code_variant_quantity_end
          expose :price
          expose :quantity
          expose :sku
          expose :brand
          expose :product_attribute_values
          expose :code_by_supplier
          expose :send_quantity, as: :sent_quantity
          expose :total_price
          expose :locations do |line_items, options|
            warehouse_variant = variant.warehouse_variants.find_by(warehouse: options[:warehouse])
            wv_locations = warehouse_variant&.warehouse_variants_locations&.where('quantity > 0')&.map do |wv_location|
              {
                id: wv_location.location_id,
                code: wv_location.location&.code,
                quantity: wv_location.quantity,
              }
            end&.uniq
            wv_locations&.sort_by { |k| k[:code] }
          end
          expose :location

          def product_id
            variant&.product_id
          end

          def product_title
            "#{product&.title} #{variant&.product_attribute_values&.map(&:value)&.join('-')} (#{sku})"
          end

          def sku
            @sku ||= variant&.sku
          end

          def brand
            product&.brand
          end

          def product_attribute_values
            variant&.product_attribute_values&.map do |attr_value|
              {
                id: attr_value&.id,
                attribute_name: attr_value&.product_attribute&.name,
                attribute_value: attr_value&.value,
              }
            end&.uniq
          end

          def code_by_supplier
            variant&.code_by_supplier
          end

          def variant
            @variant ||= Variant.unscoped.find_by(id: object.variant_id)
          end

          def product
            @product ||= Product.unscoped.find_by(id: variant.product_id, is_deleted: false)
          end

          def warehouse_id
            object.itemable&.warehouse&.id
          end

          def total_price
            object.price.to_d * object.quantity.to_i
          end

          def quantity_failed
            object.failed_qcs.quantity_failed.sum(&:quantity)
          end
        end
      end
    end
  end
end
