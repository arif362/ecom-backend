# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class Warehouses < Grape::Entity
        expose :id
        expose :name
        expose :bn_name
        expose :email
        expose :phone
        expose :districts
        expose :public_visibility
        expose :is_commission_applicable
        expose :address do |warehouse, _options|
          ShopothWarehouse::V1::Entities::Addresses.represent(warehouse.address)
        end

        def districts
          object.districts.map do |district|
            {
              id: district.id,
              name: district.name,
              bn_name: district.bn_name,
              created_by:
                {
                  id: district.created_by_id,
                  name: Staff.unscoped.find_by(id: district.created_by_id)&.name,
                },
            }
          end
        end
      end
    end
  end
end
