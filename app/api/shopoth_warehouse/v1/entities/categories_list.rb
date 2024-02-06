module ShopothWarehouse
    module V1
      module Entities
        class CategoriesList < Grape::Entity
          expose :id, as: :key
          expose :title
          expose :children do |category, _options|
            ShopothWarehouse::V1::Entities::CategoriesList.represent(category.sub_categories)
          end
      end
    end
  end
end
  