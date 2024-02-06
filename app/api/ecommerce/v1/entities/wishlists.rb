# frozen_string_literal: true

module Ecommerce
  module V1
    module Entities
      class Wishlists < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :product_id
        expose :product_title
        expose :product_price
        expose :hero_image
        expose :sku_type

        def product_id
          product&.id
        end

        def sku_type
          product&.sku_type
        end

        def product_title
          product&.title
        end

        def product_price
          variant.price_consumer.ceil
        end

        def hero_image
          image_path(product&.hero_image)
        rescue ActiveStorage::FileNotFoundError
          ''
        rescue StandardError => _error
          ''
        end

        def product
          @product ||= object&.product
        end
      end
    end
  end
end
