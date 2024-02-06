module ShopothWarehouse
  module V1
    module Entities
      class Searches < Grape::Entity
        expose :id
        expose :warehouse_id
        expose :user_id
        expose :search_key
      end
    end
  end
end
