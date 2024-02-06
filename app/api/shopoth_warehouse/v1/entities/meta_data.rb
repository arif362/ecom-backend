module ShopothWarehouse
  module V1
    module Entities
      class MetaData < Grape::Entity
        expose :id
        expose :meta_title
        expose :bn_meta_title
        expose :meta_description
        expose :bn_meta_description
        expose :meta_keyword
        expose :bn_meta_keyword
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
