# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      module LineItems
        class LineItemAttributes < Grape::Entity
          expose :id
          expose :itemable_id, as: :order_id
          expose :itemable_type, as: :order_type
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
          expose :quantity, as: :due_quantity
          expose :location
          expose :product_id
          expose :code_by_supplier
          expose :send_quantity, as: :sent_quantity
          expose :available_in_locations do |line_items, options|
            warehouse_variant = variant&.warehouse_variants&.find_by(warehouse: options[:warehouse])
            warehouse_variant&.warehouse_variants_locations&.map do |warehouse_variants_location|
              {
                id: warehouse_variants_location&.location_id,
                code: warehouse_variants_location&.location&.code,
                quantity: warehouse_variants_location&.quantity,
              }
            end&.uniq
          end

          def product_id
            variant&.product_id
          end

          def total_price
            object.price.to_d * object.quantity.to_i
          end

          def product_title
            "#{product&.title} #{variant&.product_attribute_values&.map(&:value)&.join('-')} (#{sku})"
          end

          def category_id
            product&.category_ids&.first
          end

          def sku
            @sku ||= variant&.sku
          end

          def variant
            @variant ||= Variant.unscoped.find_by(id: object.variant_id)
          end

          def product
            @product ||= Product.unscoped.find_by(id: variant.product_id, is_deleted: false)
          end

          def warehouse_id
            order = object.itemable
            order.is_a?(WhPurchaseOrder) ? central_warehouse.id : order.warehouse_id
            # purchase_order.is_a?(DhPurchaseOrder) ? purchase_order.warehouse_id : central_warehouse.id
          end

          def central_warehouse
            Warehouse.find_by(warehouse_type: 'central')
          end

          def code_by_supplier
            variant&.code_by_supplier
          end

          def quantity_failed
            object.failed_qcs.quantity_failed.sum(&:quantity)
          end
        end
      end
    end
  end
end
