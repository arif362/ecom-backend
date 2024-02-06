module Ecommerce
  module V1
    module Entities
      class ProductView < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :title
        expose :slug
        expose :description
        expose :bn_title
        expose :bn_description
        expose :is_deleted
        expose :short_description
        expose :bn_short_description
        expose :warranty_period
        expose :warranty_policy
        expose :bn_warranty_policy
        expose :inside_box
        expose :bn_inside_box
        expose :video_url
        expose :warranty_type
        expose :dangerous_goods
        expose :sku_type
        expose :max_quantity_per_order
        expose :warranty_period_type
        expose :company
        expose :bn_company
        expose :brand
        expose :categories
        expose :return_policy
        expose :bn_return_policy
        expose :certification
        expose :bn_certification
        expose :license_required
        expose :material
        expose :bn_material
        expose :bn_broad_description
        expose :consumption_guidelines
        expose :bn_consumption_guidelines
        expose :temperature_requirement
        expose :bn_temperature_requirement
        expose :keywords
        expose :tagline
        expose :product_specifications
        expose :rating_average
        expose :review_count
        expose :comment_count
        expose :variants
        expose :frequently_asked_questions
        expose :attribute_value_images
        expose :product_features
        expose :image_attribute_id
        expose :attribute_set_id
        expose :is_refundable
        expose :product_hero_image
        expose :product_images
        expose :attributes
        expose :is_emi_available
        expose :tenures

        def variants
          object.variants&.order('variants.effective_mrp ASC')&.map do |variant|
            {
              id: variant.id,
              product_attribute_values: get_product_attribute_values(variant),
              sku: variant.sku,
              weight: variant.weight,
              height: variant.height,
              price: variant.price_consumer.to_i,
              discount: variant.fetch_discount,
              available_quantity: variant.available_quantity(warehouse),
              is_available: variant.available_quantity(warehouse).positive?,
              effective_mrp: variant.customer_effective_price.to_i,
              discount_type: variant.discount_type,
              is_requested: variant.is_requested?(current_user, warehouse),
              is_wishlisted: variant.wishlisted?(current_user),
              rating_average: variant.reviews.approved.average(:rating)&.round(1)&.to_f || 0,
              review_count: variant.reviews.approved.size,
              comment_count: variant.reviews.comments.size,
              badge: variant.get_badge,
              bn_badge: variant.get_bn_badge,
              reviews: Ecommerce::V1::Entities::Reviews.represent(variant_reviews(variant)),
            }
          end
        end

        def get_product_attribute_values(variant)
          variant.product_attribute_values&.map do |product_attribute_value|
            {
              id: product_attribute_value.id,
              product_attribute_id: product_attribute_value.product_attribute_id,
              product_attribute_name: product_attribute_value.product_attribute&.name,
              value: product_attribute_value.value,
              bn_value: product_attribute_value.bn_value,
            }
          end
        end

        def rating_average
          all_reviews.average(:rating)&.round(1)&.to_f || 0
        end

        def review_count
          all_reviews&.size
        end

        def tenures
          object.tenures&.sort
        end

        def comment_count
          all_reviews&.comments&.size
        end

        def all_reviews
          @all_reviews ||= object.get_reviews
        end

        def product_hero_image
          [product_details_hero_image(object.hero_image)]
        end

        def product_images
          product_images = product_details_product_images(object.images)
          product_images.nil? ? [] : product_images
        end

        def brand
          Ecommerce::V1::Entities::BrandShortInfos.represent(object.brand) || {}
        end

        def frequently_asked_questions
          object.frequently_asked_questions.map do |faq|
            ShopothWarehouse::V1::Entities::FrequentlyAskedQuestions.represent(faq)
          end
        end

        def categories
          object.categories.as_json(only: %i(id title bn_title description bn_description slug parent_id))
        end

        def object
          @object ||= Product.find(object[:id])
        end

        def warehouse
          @warehouse ||= options[:warehouse]
        end

        def current_user
          @current_user || options[:current_user]
        end

        def variant_reviews(variant)
          variant.reviews.where(is_approved: true).where.not(description: ['', nil]).order(rating: :desc).limit(5)
        end

        def product_features
          ShopothWarehouse::V1::Entities::ProductFeatures.represent(object.product_features)
        end

        def attribute_value_images
          object.attribute_images
        end

        def attributes
          return [] unless object.creating_variable_product?

          object.attribute_set&.product_attributes&.map do |attribute|
            {
              attribute_id: attribute.id,
              attribute_name: attribute.name,
              attribute_bn_name: attribute.bn_name,
              attribute_values: attribute.product_attribute_values_variants.where(variant_id: object.variants.ids).uniq(&:product_attribute_value_id).map do |pro_attr_val_variant|
                {
                  id: pro_attr_val_variant.product_attribute_value_id,
                  value: pro_attr_val_variant.product_attribute_value.value,
                  bn_value: pro_attr_val_variant.product_attribute_value.bn_value,
                }
              end,
            }
          end
        end
      end
    end
  end
end
