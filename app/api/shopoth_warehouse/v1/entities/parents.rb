module ShopothWarehouse
  module V1
    module Entities
      class Parents < Grape::Entity
        expose :id
        expose :title
        expose :parent_category
        def parent_category
          ShopothWarehouse::V1::Entities::Parents.represent(object&.parent)
        end
      end
    end
  end
end
