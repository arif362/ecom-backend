# frozen_string_literal: true
module Ecommerce::V1::Serializers
  module WishlistSerializer
    extend Grape::API::Helpers

    def get_my_wishlist(wishlists)
      Jbuilder.new.key do |json|
        json.array! wishlists do |wishlist|
          json.id wishlist.id
          json.variant_id wishlist.variant.id
          json.product_id wishlist.variant.product.id
          json.product_title wishlist.variant.product.title
          json.product_price wishlist.variant.price_consumer.ceil
          json.product_hero_image wishlist.variant.product.main_image.service_url
        end
      end
    end
  end
end
