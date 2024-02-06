module ShopothWarehouse
  module V1
    module Entities
      class PromotionVariants < Grape::Entity
        expose :id
        expose :promotion_id
        expose :variant_id
        expose :state
        expose :sku
        expose :created_by
        # expose :variant

        def sku
          object&.variant&.sku
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
