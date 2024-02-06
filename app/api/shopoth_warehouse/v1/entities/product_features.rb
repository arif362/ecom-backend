# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class ProductFeatures < Grape::Entity
        expose :id
        expose :title
        expose :bn_title
        expose :description
        expose :bn_description
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
