module ShopothWarehouse
  module V1
    module Entities
      class Thanas < Grape::Entity
        expose :id
        expose :district_id
        expose :distributor_id
        expose :name
        expose :bn_name
        expose :home_delivery
      end
    end
  end
end
