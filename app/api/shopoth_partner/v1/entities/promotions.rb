module ShopothPartner
  module V1
    module Entities
      class Promotions < Grape::Entity
        expose :id, as: :promotion_id
        expose :title, as: :promotion_title
        expose :promotion_category, as: :promotion_description
        expose :promotion_coupons do |promotions, options|
          ra_coupons = object.coupons.where(usable_type: 'RetailerAssistant', usable_id: options[:retailer_assistant].id)
          ShopothPartner::V1::Entities::RaCoupons.represent(ra_coupons)
        end
      end
    end
  end
end
