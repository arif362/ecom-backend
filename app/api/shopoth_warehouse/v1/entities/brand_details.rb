module ShopothWarehouse
  module V1
    module Entities
      class BrandDetails < Grape::Entity
        expose :id, as: :value
        expose :name, as: :label
      end
    end
  end
end
