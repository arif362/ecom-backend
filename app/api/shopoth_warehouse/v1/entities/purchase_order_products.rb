module ShopothWarehouse
  module V1
    module Entities
      class PurchaseOrderProducts < Grape::Entity
        expose :id
        expose :title
        expose :variants do |product, _options|
          ShopothWarehouse::V1::Entities::PurchaseOrderVariants.represent(product.variants, product: product.id)
        end
      end
    end
  end
end
