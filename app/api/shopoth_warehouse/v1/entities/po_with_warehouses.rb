module ShopothWarehouse
  module V1
    module Entities
      class PoWithWarehouses < Grape::Entity
        expose :id
        expose :warehouse_id
        expose :warehouse_name
        expose :warehouse_district
        expose :order_status
        expose :order_by
        expose :quantity
        expose :total_price
        expose :order_date
        expose :created_at

        def warehouse_name
          warehouse&.name
        end

        def warehouse_district
          warehouse&.address&.district
        end

        def order_status
          status = object.order_status
          status == 'received_to_dh' ? 'Received' : status.humanize
        end

        def warehouse
          @warehouse ||= object&.warehouse
        end
      end
    end
  end
end
