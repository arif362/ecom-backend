module ShopothWarehouse
  module V1
    module Entities
      class SkuDetails < Grape::Entity
        expose :id, as: :value
        expose :sku, as: :label
      end
    end
  end
end
