module Ecommerce
  module V1
    module Entities
      class Products < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :title
        expose :bn_title
        expose :discount
        expose :discount_stringify
        expose :discounted_price
        expose :get_product_base_price, as: :product_base_price
        expose :variant_id
        expose :hero_image
        expose :slug
        expose :sku_type

        def discount
          object.discount.to_s
        end

        def hero_image
          thumb_product_image_path(object.hero_image)
        end

        def variant_id
          object.min_emrp_variant&.id
        end
      end
    end
  end
end
