module ShopothWarehouse
  module V1
    module Entities
      class Brands < Grape::Entity
        include ShopothWarehouse::V1::Helpers::ImageHelper

        expose :id
        expose :name
        expose :bn_name
        expose :slug
        expose :logo, as: :logo_file
        expose :banners
        expose :is_own_brand
        expose :slug
        expose :brand_info_visible
        expose :public_visibility
        expose :homepage_visibility
        expose :branding_layout
        expose :branding_promotion_with
        expose :branding_video_url
        expose :branding_image, as: :branding_image_file
        expose :branding_title
        expose :branding_title_bn
        expose :branding_subtitle
        expose :branding_subtitle_bn
        expose :short_description
        expose :short_description_bn
        expose :more_info_button_text
        expose :more_info_button_text_bn
        expose :more_info_url
        expose :product_count
        expose :campaigns, as: :campaigns_attributes, with: ShopothWarehouse::V1::Entities::Campaigns
        expose :filtering_options, as: :filtering_options_attributes, with: ShopothWarehouse::V1::Entities::FilteringOptions
        expose :redirect_url
        expose :meta_info
        expose :created_by

        def logo
          object.logo.service_url if object&.logo&.attached?
        end

        def banners
          return [] unless object&.banners&.present?

          image_paths_with_id(object.banners)
        end

        def branding_image
          object.branding_image.service_url if object&.branding_image&.attached?
        end

        def product_count
          object.products.size
        end

        def meta_info
          ShopothWarehouse::V1::Entities::MetaData.represent(object.meta_datum)
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
