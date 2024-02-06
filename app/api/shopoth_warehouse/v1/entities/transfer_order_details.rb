module ShopothWarehouse
  module V1
    module Entities
      class TransferOrderDetails < Grape::Entity
        expose :id
        expose :warehouse_id
        expose :order_by
        expose :quantity
        expose :total_price
        expose :order_status
        expose :qc_status
        expose :created_at, as: :order_date
        expose :line_items do |return_order, options|
          box_item_ids = return_order.box_line_items.pluck(:line_item_id)
          line_items = return_order.line_items.where.not(id: box_item_ids)
          if line_items.present?
            ShopothWarehouse::V1::Entities::LineItems::ItemWithLocations.represent(
              line_items, warehouse: options[:warehouse]
            )
          else
            []
          end
        end
        expose :boxes do |purchase_order, options|
          ShopothWarehouse::V1::Entities::Boxes.represent(
            purchase_order.boxes, warehouse: options[:warehouse]
          )
        end
        expose :created_by

        def qc_status
          object&.line_items&.map { |line_item| line_item.qc_status }&.all?(true)
        end

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
