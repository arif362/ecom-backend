# frozen_string_literal: true
module Ecommerce::V1::Serializers
  module ProductSerializer
    extend Grape::API::Helpers
    include Ecommerce::V1::Helpers::ImageHelper

    def get_product_details(product, variants, warehouse, current_user = '', reviews)
      Jbuilder.new.key do |json|
        json.product_id product.id
        json.title product.title
        json.bn_title product.bn_title
        json.description product.description
        json.bn_description product.bn_description
        json.short_description product.short_description
        json.bn_short_description product.bn_short_description
        json.slug product.slug
        json.is_refundable product.is_refundable
        json.return_policy product.return_policy
        json.bn_return_policy product.bn_return_policy
        json.warranty_policy product.warranty_policy
        json.bn_warranty_policy product.bn_warranty_policy
        json.inside_box product.inside_box
        json.bn_inside_box product.bn_inside_box
        json.company product.company
        json.bn_company product.bn_company
        json.certification product.certification
        json.bn_certification product.bn_certification
        json.material product.material
        json.bn_material product.bn_material
        json.consumption_guidelines product.consumption_guidelines
        json.bn_consumption_guidelines product.bn_consumption_guidelines
        json.temperature_requirement product.temperature_requirement
        json.bn_temperature_requirement product.bn_temperature_requirement
        json.image_attribute_id product.image_attribute_id
        json.attribute_set_id product.attribute_set_id
        json.review_rating reviews&.average(:rating) || 0
        json.review_count reviews&.size
        json.comment_count reviews.pluck(:description)&.reject(&:blank?)&.size
        json.reviews get_reviews(reviews)
        json.product_images select_product_main_img(product)
        json.brand get_brand_details(product&.brand)
        json.product_categories get_product_categories(product.categories.reverse)
        json.variants get_variants_details(variants, warehouse, current_user)
        if product.product_attribute_images.present?
          json.product_attribute_images do
            product.product_attribute_images&.each { |pa| json.set! pa.product_attribute_value_id, image_paths(pa.images) || [""] }
          end
        else
          json.product_attribute_images []
        end

        if product.product_features.count.positive?
          json.product_features get_product_features(product.product_features)
        else
          json.product_features []
        end
      end
    end

    def get_grid_product_list(products, current_user = '', warehouse = '')
      Jbuilder.new.key do |json|
        json.array! products do |product|
          brand = product.brand
          min_variant = product.min_emrp_variant
          json.id product.id
          json.title product.title
          json.bn_title product.bn_title
          json.image_url thumb_product_image_path(product.hero_image)
          # TODO: Product view url
          json.view_url get_product_show_url(product.id)
          json.price product.get_product_base_price.to_i
          json.discount product.discount.to_s
          json.discount_stringified product.discount_stringify
          json.effective_mrp product.discounted_price.to_i
          json.brand_id brand&.id
          json.brand_name brand&.name
          json.brand_name_bn brand&.bn_name
          json.variant_id min_variant&.id
          json.is_wishlisted min_variant&.wishlisted?(current_user)
          json.badge product&.promo_tag
          json.bn_badge product&.bn_promo_tag
          json.slug product.slug
          json.sell_count product.sell_count
          json.max_quantity_per_order product.max_quantity_per_order
          json.sku_type product.sku_type
          json.root_category product.root_category&.as_json(only: [:id, :slug, :title, :bn_title])
          json.available_quantity product.product_available_quantity(warehouse)
          json.is_available product.product_available_quantity(warehouse).positive? || false
          json.is_requested min_variant&.is_requested?(current_user, warehouse) || false
        end
      end
    end

    def get_product_show_url(id)
      "/products/details/#{id}"
    end

    def select_product_main_img(product)
      product_image = image_paths(product.images)
      product_image.nil? ? [product.master_img('product')] : product_image
    end

    def get_variants_details(variants, warehouse, current_user)
      Jbuilder.new.key do |json|
        json.array! variants do |variant|
          json.variant_id variant.id
          json.product_attribute_values variant.product_attribute_values.ids
          json.sku variant.sku
          json.weight variant.weight
          json.height variant.height
          json.price variant.price_consumer.to_i
          json.discount variant.fetch_discount
          json.available_quantity get_available_quantity(variant, warehouse)
          json.is_available get_available_quantity(variant, warehouse).positive? ? true : false
          json.effective_mrp variant.customer_effective_price.to_i
          json.discount_type variant.discount_type
          json.is_requested variant.is_requested?(current_user)
        end
      end
    end

    def get_available_quantity(variant, warehouse)
      variant&.warehouse_variants.find_by(warehouse_id: warehouse&.id)&.available_quantity.to_i
    end

    def get_product_features(product_features)
      Jbuilder.new.key do |json|
        json.array! product_features do |feature|
          json.id feature.id
          json.title feature.title
          json.bn_title feature.bn_title
          json.description feature.description
          json.bn_description feature.bn_description
        end
      end
    end

    def get_reviews(reviews)
      Jbuilder.new.key do |json|
        json.array! reviews do |review|
          json.id review.id
          json.title review.title
          json.rating review.rating
          json.description review.description
          json.user_name review.user&.full_name
          json.is_recommended review.is_recommended
          json.is_approved review.is_approved
        end
      end
    end

    def get_product_categories(categories)
      Jbuilder.new.key do |json|
        json.array! categories do |category|
          json.id category.id
          json.title category.title
          json.bn_title category.bn_title
          json.slug category.slug
        end
      end
    end

    def get_brand_details(brand)
      Jbuilder.new.key do |json|
        json.brand_id brand.id
        json.name brand.name
        json.bn_name brand.bn_name
        json.is_own_brand brand.is_own_brand
        json.slug brand.slug
        json.logo image_path(brand.logo)
        json.banner image_path(brand.banner)
      end
    end
  end
end
