module ShopothWarehouse
  module V1
    module Entities
      class ProductAttributes < Grape::Entity
        expose :id
        expose :name
        expose :bn_name
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
