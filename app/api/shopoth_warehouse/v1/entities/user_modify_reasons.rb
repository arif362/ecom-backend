module ShopothWarehouse
  module V1
    module Entities
      class UserModifyReasons < Grape::Entity
        expose :id
        expose :title
        expose :title_bn
        expose :reason_type
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
