module Ecommerce
  module V1
    module Entities
      class SiblingCategories < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :title
        expose :bn_title
        expose :position
        expose :slug
        expose :image
        expose :banner_image
        expose :sub_categories

        def image
          image_path(object&.image)
        end

        def banner_image
          image_path(object&.banner_image)
        end

        def sub_categories
          Ecommerce::V1::Entities::ParentCategories.represent(object.sub_categories.
            where(home_page_visibility: true))
        end
      end
    end
  end
end
