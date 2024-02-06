module Ecommerce
  module V1
    module Entities
      class HomePageProductList < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :title
        expose :bn_title
        expose :image_url
        expose :view_url
        expose :price
        expose :discount
        expose :discount_stringified
        expose :effective_mrp
        expose :brand_id
        expose :brand_name
        expose :brand_name_bn
        expose :variant_id
        expose :is_wishlisted
        expose :badge
        expose :bn_badge
        expose :slug
        expose :sell_count
        expose :max_quantity_per_order
        expose :sku_type
        expose :available_quantity
        expose :is_available
        expose :is_requested

        def brand
          object&.brand
        end

        def min_variant
          object&.min_emrp_variant
        end

        def min_emrp_variant
          @min_emrp_variant ||= variants.min_by(&:customer_effective_price)
        end

        def image_url
          thumb_product_image_path(object&.hero_image)
        end

        def view_url
          "/products/details/#{object&.id}"
        end

        def price
          object&.get_product_base_price.to_i
        end

        def discount
          object&.discount.to_s
        end

        def discount_stringified
          object&.discount_stringify
        end

        def effective_mrp
          object&.discounted_price.to_i
        end

        def brand_id
          brand&.id
        end

        def brand_name
          brand&.name
        end

        def brand_name_bn
          brand&.bn_name
        end

        def variant_id
          min_variant&.id
        end

        def is_wishlisted
          min_variant&.wishlisted?(current_user)
        end

        def badge
          object&.promo_tag
        end

        def bn_badge
          object&.promo_tag
        end

        def available_quantity
          object&.product_available_quantity(warehouse)
        end

        def is_available
          available_quantity.positive? || false
        end

        def is_requested
          min_variant&.is_requested?(current_user, warehouse) || false
        end

        def current_user
          @current_user || options[:current_user]
        end

        def warehouse
          options[:warehouse]
        end
      end
    end
  end
end
