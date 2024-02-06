# frozen_string_literal: true

module Ecommerce::V1::Serializers
  module ProductCategorySerializer
    extend Grape::API::Helpers

    include Ecommerce::V1::Helpers::ImageHelper

    def get_category_info(category)
      Jbuilder.new.category do |json|
        json.id category.id
        json.title category.title
        json.bn_title category.bn_title
        json.image_url image_path(category.image)
        json.slug category.slug
      end
    end

    def show_by_product_category(products)
      Jbuilder.new.products do |json|
        json.array! products do |product|
          json.id product.id
          json.title product.title
          json.bn_title product.bn_title
          json.image_url thumb_image(product.main_image)
          # TODO: Product view url
          # json.view_url show_product_page(product.id)
          json.price product.get_product_base_price.to_i
          json.discount product.discount
          json.discount_stringified product.discount_stringify
          json.effective_mrp product.discounted_price.to_i
          json.slug product.slug
        end
      end
    end

    def show_flash_sales_product(promotion_variants, current_user = '')
      Jbuilder.new.products do |json|
        json.array! promotion_variants do |promotion_variant|
          product = promotion_variant.product
          variant = promotion_variant.variant
          brand = product.brand
          json.id product.id
          json.title product.title
          json.bn_title product.bn_title
          json.image_url thumb_image(product.main_image)
          # TODO: Product view url
          json.view_url get_product_show_url(product.id)
          json.price product.get_product_base_price.to_i
          json.discount product.discount
          json.discount_stringified product.discount_stringify
          json.effective_mrp product.discounted_price.to_i
          json.brand_id brand&.id
          json.brand_name brand&.name
          json.brand_name_bn brand&.bn_name
          json.variant_id variant&.id
          json.is_wishlisted variant&.wishlisted?(current_user)
          json.badge product&.promo_tag
          json.sku_type product.sku_type
        end
      end
    end

    def show_product_page(id)
      # TODO: Product view url
    end

    # def brand_info(brands)
    #   Jbuilder.new.brands do |json|
    #     json.array! brands do |brand|
    #       json.id brand&.id
    #       json.name brand&.name
    #       json.bn_name brand&.bn_name
    #       json.logo image_path(brand&.logo)
    #       json.banner image_path(brand&.banner)
    #       json.slug brand&.slug
    #     end
    #   end
    # end
  end
end
