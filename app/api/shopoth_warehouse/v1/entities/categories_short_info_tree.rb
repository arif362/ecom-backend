module ShopothWarehouse
  module V1
    module Entities
      class CategoriesShortInfoTree < Grape::Entity
        expose :id
        expose :title
        expose :slug
        expose :parent_category

        def parent_category
          ShopothWarehouse::V1::Entities::Parents.represent(object&.parent)
        end
      end
    end
  end
end
