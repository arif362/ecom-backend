module ShopothWarehouse
  module V1
    module Entities
      class Locations < Grape::Entity
        expose :id
        expose :code
        expose :created_by
        expose :variants do |location, options|
          wv_locations = location.warehouse_variants_locations.where('quantity > 0')
          wv_locations.map do |wv_location|
            variant = wv_location.warehouse_variant&.variant
            next unless variant

            {
              product_id: variant.product_id,
              product_title: Product.unscoped.find_by(id: variant.product_id, is_deleted: false)&.title,
              variant_id: variant.id,
              sku: variant.sku,
              quantity: wv_location.quantity,
            }
          end.flatten.compact.uniq
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
