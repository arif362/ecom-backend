module ShopothWarehouse
  module V1
    module Entities
      class Categories < Grape::Entity
        include ShopothWarehouse::V1::Helpers::ImageHelper

        expose :id
        expose :title
        expose :position
        expose :description
        expose :slug
        expose :parent_id
        expose :parent
        expose :parent_category
        expose :bn_title
        expose :image
        expose :banner_image
        expose :bn_description
        expose :home_page_visibility
        expose :sub_categories do |category, _options|
          ShopothWarehouse::V1::Entities::Categories.represent(category.sub_categories)
        end
        expose :meta_info
        expose :business_type
        expose :created_by

        def image
          image_path(object.image)
        end

        def banner_image
          image_path(object.banner_image)
        end

        def parent
          object&.parent&.title
        end

        def parent_category
          ShopothWarehouse::V1::Entities::Parents.represent(object&.parent)
        end

        def meta_info
          ShopothWarehouse::V1::Entities::MetaData.represent(object.meta_datum)
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
