module ShopothWarehouse
  module V1
    module Entities
      class TransferOrderList < Grape::Entity
        expose :id
        expose :warehouse_id
        expose :order_by
        expose :quantity
        expose :total_price
        expose :order_status
        expose :created_at
        expose :warehouse_name

        def warehouse_name
          object&.warehouse&.name
        end
      end
    end
  end
end
