# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class Boxes < Grape::Entity
        expose :id
        expose :status
        expose :line_items do |box, options|
          ShopothWarehouse::V1::Entities::LineItems::ItemWithLocations.represent(
            box.line_items, warehouse: options[:warehouse]
          )
        end
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
