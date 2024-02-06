module ShopothWarehouse
  module V1
    module Entities
      class PromotionRules < Grape::Entity
        expose :id
        expose :promotion_id
        expose :name
        expose :value
      end
    end
  end
end
