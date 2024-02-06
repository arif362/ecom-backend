module Ecommerce
  module V1
    module Entities
      class BrandCategory < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :title
        expose :bn_title
        expose :slug
        expose :image

        def image
          image_path(object&.image)
        rescue
          ''
        end

        def banner_image
          image_path(object&.banner_image)
        rescue
          ''
        end
      end
    end
  end
end
