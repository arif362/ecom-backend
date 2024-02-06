module ShopothWarehouse
  module V1
    module Entities
      class FlashSaleVariant < Grape::Entity
        expose :id
        expose :promotion_id
        expose :variant_id
        expose :sku
        expose :promotional_price
        expose :promotional_discount

        def sku
          object&.variant&.sku
        end
      end
    end
  end
end
