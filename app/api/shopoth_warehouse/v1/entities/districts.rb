module ShopothWarehouse
  module V1
    module Entities
      class Districts < Grape::Entity
        expose :id
        expose :name
        expose :bn_name
        expose :warehouse_id
        expose :dwh_assigned

        def dwh_assigned
          object.warehouse.present?
        end
      end
    end
  end
end
