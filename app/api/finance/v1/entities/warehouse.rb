module Finance
  module V1
    module Entities
      class Warehouse < Grape::Entity
        expose :id
        expose :name
        expose :bn_name
        expose :email
        expose :phone
        expose :public_visibility
        expose :address do |warehouse, _options|
          ShopothWarehouse::V1::Entities::Addresses.represent(warehouse.address)
        end
      end
    end
  end
end
