module Ecommerce
  module V1
    module Entities
      class PartnersSearch < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :name
        expose :phone
        expose :schedule
        expose :image
        expose :latitude
        expose :longitude
        expose :partner_code
        expose :retailer_code
        expose :slug
        expose :favourite_store?, as: :favourite_store
        expose :address
        expose :reviews

        def address
          {
            district_id: partner_address&.district_id,
            district_name: partner_address&.district&.name,
            thana_id: partner_address&.thana_id,
            thana_name: partner_address&.thana&.name,
            area_id: partner_address&.area_id,
            area_name: partner_address&.area&.name,
            address_line: partner_address&.address_line,
            post_code: partner_address&.zip_code,
          }
        end

        def outlet_name
          object.name
        end

        def image
          image_path(object&.image) || nil
        end

        def reviews
          {
            rating_count: approved_reviews.size,
            rating_avg: (approved_reviews&.average(:rating)&.round(1) || 0).to_s,
            comments_count: approved_reviews&.pluck(:description)&.reject(&:blank?)&.size,
          }
        end

        def favourite_store?
          options[:user]&.favorite_stores&.where(partner_id: object.id).present? || false
        end

        def approved_reviews
          @approved_reviews ||= object&.reviews&.where(is_approved: true)
        end

        def partner_address
          @partner_address ||= object&.address
        end
      end
    end
  end
end
