# frozen_string_literal: true

module Ecommerce
  module V1
    module Entities
      class Sliders < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :name
        expose :body
        expose :link_url
        expose :position
        expose :img_type
        expose :image

        def image
          coupon_slider_image_url(object.image)
        end
      end
    end
  end
end
