module Ecommerce
  module V1
    module Entities
      class BrandShortInfos < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :name
        expose :bn_name
        expose :logo
        expose :is_own_brand
        expose :slug
        expose :public_visibility
        expose :homepage_visibility
        expose :followed?, as: :is_followed
        expose :redirect_url

        def logo
          brand_logo_image_path(object.logo)
        rescue
          Rails.logger.error "Brand's logo not found."
          ''
        end

        def followed?
          options[:current_user].present? && options[:current_user].brand_followings.where(brand_id: object.id).present?
        end
      end
    end
  end
end

