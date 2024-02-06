module Ecommerce
  module V1
    module Entities
      class Brands < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :name
        expose :bn_name
        expose :logo
        expose :banners
        expose :is_own_brand
        expose :slug
        expose :brand_info_visible
        expose :brand_info
        expose :meta_info
        expose :is_followed
        expose :campaigns, with: Ecommerce::V1::Entities::Campaigns
        expose :category_filter_options
        expose :product_attribute_filter_options
        expose :price_filter_options
        expose :product_type_filter_options
        expose :keyword_filter_options
        expose :redirect_url

        def brand_info
          {
            branding_layout: object.branding_layout,
            branding_promotion_with: object.branding_promotion_with,
            branding_video_url: object.branding_video_url,
            branding_image: branding_image,
            branding_title: object.branding_title,
            branding_title_bn: object.branding_title_bn,
            branding_subtitle: object.branding_subtitle,
            branding_subtitle_bn: object.branding_subtitle_bn,
            short_description: object.short_description,
            short_description_bn: object.short_description_bn,
            more_info_button_text: object.more_info_button_text,
            more_info_button_text_bn: object.more_info_button_text_bn,
            more_info_url: object.more_info_url,
          }
        end

        def meta_info
          object.meta_datum&.as_json(only: %i(meta_title bn_meta_title meta_description bn_meta_description meta_keyword bn_meta_keyword)) || {}
        end

        def logo
          brand_logo_image_path(object.logo) if object&.logo&.attached?
        end

        def banners
          if object.banners.present?
            brand_banner_image_paths(object.banners, options[:request_source])
          else
            []
          end
        end

        def branding_image
          if object&.branding_image&.attached? && object&.full?
            brand_full_branding_image_path(object.branding_image)
          elsif object&.branding_image&.attached?
            brand_box_branding_image_path(object.branding_image)
          else
            ''
          end
        end

        def product_attribute_filter_options
          product_attribute_filter = object&.filtering_options&.product_attribute&.first
          if product_attribute_filter.present?
            product_attributes = product_attribute_filter.filtering_keys.map {|product_attribute_id| ProductAttribute.find_by(id: product_attribute_id)}
            Ecommerce::V1::Entities::ProductAttributes.represent(product_attributes)
          end
        end

        def category_filter_options
          category_filter = object&.filtering_options&.category&.first
          if category_filter.present?
            categories = category_filter.filtering_keys.map {|category_id| Category.find_by(id: category_id)}
            Ecommerce::V1::Entities::BrandCategory.represent(categories)
          end
        end

        def product_type_filter_options
          product_type_filter = object&.filtering_options&.product_type&.first
          if product_type_filter.present?
            product_types = product_type_filter.filtering_keys.map {|product_type_id| ProductType.find_by(id: product_type_id)}
            Ecommerce::V1::Entities::ProductTypes.represent(product_types)
          end
        end

        def price_filter_options
          price_filter = object&.filtering_options&.price_range&.first
          if price_filter.present?
            prices = object&.products&.publicly_visible&.map{ |p| p.get_product_base_price }
            {
              max: prices&.max&.ceil,
              min: prices&.min&.floor,
            }
          end
        end

        def keyword_filter_options
          object&.filtering_options&.keyword&.first&.filtering_keys
        end

        def is_followed
          options[:current_user].present? && options[:current_user].brand_followings.where(brand_id: object.id).present?
        end
      end
    end
  end
end
