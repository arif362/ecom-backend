module ShopothWarehouse
  module V1
    module Entities
      class Slide < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :name
        expose :published
        expose :link_url
        expose :img_type
        expose :image_type_value
        expose :body
        expose :position
        expose :image
        expose :created_by

        def image
          object.homepage_slider? ? homepage_slider_image_url(object.image) : banner_image_url(object.image)
        end

        def image_type_value
          object.get_image_type_value
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
