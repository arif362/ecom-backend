module ShopothPartner
  module V1
    module Entities
      class RaCoupons < Grape::Entity
        expose :id, as: :coupon_id
        expose :code, as: :coupon_code
        expose :is_used, as: :coupon_used
        expose :usable_id, as: :retailer_assistant_id
      end
    end
  end
end
