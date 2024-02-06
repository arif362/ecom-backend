module ShopothWarehouse
  module V1
    module Entities
      class WarehouseVariants < Grape::Entity
        expose :variant_id
        expose :product_id
        expose :product_title
        expose :sku
        expose :inventory_status do
          expose :available_quantity
          expose :booked_quantity
          expose :packed_quantity
        end
        expose :created_by

        def variant_id
          variant.id
        end

        def product_id
          variant&.product&.id
        end

        def product_title
          "#{variant.product&.title} #{variant&.product_attribute_values&.map(&:value)&.join('-')} (#{sku})"
        end

        def sku
          variant&.sku
        end

        def variant
          object.variant
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
