module ShopothWarehouse
  module V1
    module Entities
      class RaCoupons < Grape::Entity
        expose :id
        expose :promotion_id
        expose :retailer_assistant_id
        expose :code
      end
    end
  end
end
