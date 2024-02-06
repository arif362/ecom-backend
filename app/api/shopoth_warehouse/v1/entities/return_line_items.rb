module ShopothWarehouse
  module V1
    module Entities
      class ReturnLineItems < Grape::Entity
        expose :id
        expose :itemable_id, as: :return_transfer_order_id
        expose :received_quantity
        expose :qc_passed
        expose :qc_failed, as: :quality_failed
        expose :quantity_failed
        expose :qc_status
        expose :variant_id
        expose :product_title
        expose :sku
        expose :category_id
        expose :price
        expose :total_price
        expose :quantity
        expose :location
        expose :product_id
        expose :code_by_supplier
        expose :available_in_locations do |line_items, options|
          warehouse_variant = object.variant.warehouse_variants.find_by(warehouse: options[:warehouse])
          warehouse_variant&.warehouse_variants_locations&.map do |warehouse_variants_location|
            {
              id: warehouse_variants_location.location_id,
              code: warehouse_variants_location.location&.code,
              quantity: warehouse_variants_location.quantity,
            }
          end&.uniq
        end

        def product_id
          object&.variant&.product_id
        end

        def total_price
          object.price.to_d * object.quantity.to_i
        end

        def product_title
          "#{variant.product&.title} #{variant.product_attribute_values&.map(&:value)&.join('-')} (#{sku})"
        end

        def category_id
          variant.product&.category_ids&.first
        end

        def sku
          @sku ||= variant&.sku
        end

        def variant
          @variant ||= Variant.find(object.variant_id)
        end

        def warehouse_id
          purchase_order = object.itemable
          purchase_order.is_a?(DhPurchaseOrder) ? purchase_order.warehouse_id : central_warehouse.id
        end

        def central_warehouse
          Warehouse.find_by(warehouse_type: 'central')
        end

        def code_by_supplier
          variant.code_by_supplier
        end

        def quantity_failed
          object.failed_qcs.quantity_failed.sum(&:quantity)
        end
      end
    end
  end
end
