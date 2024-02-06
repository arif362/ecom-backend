module ShopothWarehouse
  module V1
    module Entities
      class RoutePhones < Grape::Entity
        expose :id
        expose :phone
      end
    end
  end
end
