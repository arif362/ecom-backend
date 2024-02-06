module Ecommerce
  module V1
    module Entities
      class FavoriteStores < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :partner_id
        expose :name
        expose :phone
        expose :schedule
        expose :image
        expose :latitude
        expose :longitude
        expose :slug
        expose :favourite_store?, as: :favourite_store
        expose :address
        expose :reviews

        def name
          partner&.name
        end

        def phone
          partner&.phone
        end

        def schedule
          partner&.schedule
        end

        def latitude
          partner&.latitude
        end

        def longitude
          partner&.longitude
        end

        def slug
          partner&.slug
        end

        def favourite_store?
          options[:user].favorite_stores&.where(partner: object.partner_id).present?
        end

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

        def image
          image_variant_path(partner&.image)&.dig(:small_img)
        rescue ActiveStorage::FileNotFoundError
          nil
        rescue StandardError => _error
          nil
        end

        def reviews
          rating_count = approved_reviews&.size
          comment_count = approved_reviews&.pluck(:description)&.reject(&:blank?)&.size
          rating_avg = approved_reviews&.average(:rating)&.round(1)&.to_f || 0
          { rating_count: rating_count, rating_avg: rating_avg, comments_count: comment_count }
        end

        def approved_reviews
          @approved_reviews ||= partner&.reviews&.where(is_approved: true)
        end

        def partner_address
          @partner_address ||= partner&.address
        end

        def partner
          @partner ||= object&.partner
        end
      end
    end
  end
end
