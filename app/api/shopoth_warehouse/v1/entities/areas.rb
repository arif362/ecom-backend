module ShopothWarehouse
  module V1
    module Entities
      class Areas < Grape::Entity
        expose :id
        expose :thana_id
        expose :name
        expose :bn_name
        expose :home_delivery
      end
    end
  end
end
