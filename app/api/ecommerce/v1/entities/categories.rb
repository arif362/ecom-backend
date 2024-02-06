module Ecommerce
  module V1
    module Entities
      class Categories < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :title
        expose :bn_title
        expose :position
        expose :slug
        expose :image
        expose :banner_image
        expose :root_parent
        expose :sub_categories
        expose :bread_crumbs

        def image
          image_path(object&.image)
        end

        def banner_image
          return nil unless object&.banner_image.present?

          category_banner_image_path(object&.banner_image, options[:request_source])
        end

        def root_parent
          Ecommerce::V1::Entities::ParentCategories.represent(object.pick_parent)
        end

        def sub_categories
          Ecommerce::V1::Entities::SiblingCategories.represent(object.sub_categories.visible_categories)
        end

        def bread_crumbs
          object.add_bread_crumbs(bread_crumbs = [])
        end
      end
    end
  end
end
