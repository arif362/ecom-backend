module ShopothWarehouse
  module V1
    module Entities
      class ReturnRequestWithLocations < Grape::Entity
        expose :id, as: :return_id
        expose :customer_order_id
        expose :return_type
        expose :return_status
        expose :product_details
        expose :receiver_type
        expose :quantity
        expose :available_in_locations do |line_items, options|
          wv_locations = {}
          if object.unpacked? && variant.present?
            warehouse_variant = variant&.warehouse_variants&.find_by(warehouse: options[:warehouse])
            wv_locations = warehouse_variant&.warehouse_variants_locations&.map do |wv_location|
              {
                id: wv_location.location.id,
                code: wv_location.location.code,
                quantity: wv_location.quantity,
              }
            end&.uniq
          end
          wv_locations
        end

        def customer_order_id
          object.customer_order_id
        end

        def product_details
          product_details = {}
          if object.unpacked?
            product_details = {
              line_item_id: object&.shopoth_line_item_id,
              category_id: category_id,
              title: variant&.product&.title,
              sku: variant&.sku,
              price: object&.shopoth_line_item&.effective_unit_price,
              product_attribute_values: product_attribute,
            }
          elsif object.packed?
            product_details = {
              price: object&.customer_order&.total_price,
              title: 'Full order',
            }
          end
          product_details
        end

        def receiver_type
          receiver = 'Route'
          receiver = 'Rider' if object.rider_id.present?
          receiver
        end

        def product_attribute
          variant&.product_attribute_values&.map do |attr_val|
            {
              id: attr_val.id,
              name: attr_val&.product_attribute&.name,
              value: attr_val.value,
            }
          end
        end

        def variant
          @variant ||= object&.shopoth_line_item&.variant
        end

        def category_id
          Product.unscoped.find_by(id: variant&.product_id)&.category_ids&.first
        end

        def return_type
          object.return_type.titleize
        end
      end
    end
  end
end
