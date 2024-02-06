# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class Distributors < Grape::Entity
        expose :id
        expose :name
        expose :bn_name
        expose :warehouse_id
        expose :email
        expose :phone
        expose :address
        expose :code
        expose :status
        expose :created_by

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
