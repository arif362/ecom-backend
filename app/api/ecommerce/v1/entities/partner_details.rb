module Ecommerce
  module V1
    module Entities
      class PartnerDetails < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :name
        expose :outlet_name
        expose :owner_name
        expose :partner_code
        expose :phone
        expose :address
        expose :schedule
        expose :image
        expose :latitude
        expose :longitude
        expose :favourite_store
        expose :customer_reviews
        expose :reviews
        expose :work_days
        expose :slug

        def outlet_name
          I18n.locale == :en ? object.name : object.bn_name
        end

        def address
          {
            district_name: object&.address&.district&.name,
            thana_name: object&.address&.thana&.name,
            area_name: object&.address&.area&.name,
            address_line: object&.address&.address_line,
            post_code: object&.address&.zip_code,
          }
        end

        def image
          image_variant_path(object&.image)&.dig(:small_img)
        rescue ActiveStorage::FileNotFoundError
          nil
        rescue StandardError => _error
          nil
        end

        def favourite_store
          options[:user]&.favorite_stores&.where(partner: object)&.present? || false
        end

        def customer_reviews
          rating_count = approved_reviews&.size
          rating_avg = approved_reviews&.average(:rating)&.round(1).to_s || '0'
          comment_count = approved_reviews&.pluck(:description)&.reject(&:blank?)&.size
          recommended = approved_reviews&.where(is_recommended: true)&.size
          recommended_percent = rating_count.positive? ? ((recommended.to_f / rating_count) * 100).round(1).to_s : '0'
          {
            rating_count: rating_count,
            rating_avg: rating_avg,
            comment_count: comment_count,
            recommended: recommended,
            recommended_percent: recommended_percent,
            specified_star_count: star_count,
          }
        end

        def reviews
          Ecommerce::V1::Entities::Reviews.represent(approved_reviews)
        end

        def star_count
          specified_star_count_hash = approved_reviews&.group(:rating)&.count
          star_count = { '5': 0, '4': 0, '3': 0, '2': 0, '1': 0 }
          specified_star_count_hash.each do |k, v|
            star_count[k] = v
          end
          star_count
        end

        def approved_reviews
          @approved_reviews ||= object&.reviews&.where(is_approved: true)
        end
      end
    end
  end
end
