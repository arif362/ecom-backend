# frozen_string_literal: true

module Ecommerce
  module V1
    module Entities
      class PromoBanners < Grape::Entity

        expose :id
        expose :title
        expose :layout
        expose :is_visible
        expose :app_images
        expose :web_images

        def app_images
          object.banner_images.app.map do |image|
            {
              id: image.id,
              image_title: image.image_title,
              description: image.description,
              image_type: image.image_type,
              redirect_url: image.redirect_url,
              image_url: image.image.service_url,
            }
          end
        end

        def web_images
          object.banner_images.web.map do |image|
            {
              id: image.id,
              image_title: image.image_title,
              description: image.description,
              image_type: image.image_type,
              redirect_url: image.redirect_url,
              image_url: image.image.service_url,
            }
          end
        end
      end
    end
  end
end
