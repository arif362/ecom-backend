# frozen_string_literal: true

module Ecommerce
  module V1
    module Entities
      class User < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :full_name
        expose :email
        expose :phone
        expose :images

        def images
          images_paths(object&.image)
        end
      end
    end
  end
end
