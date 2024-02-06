module ShopothWarehouse
  module V1
    module Entities
      class CustomerOrderList < Grape::Entity
        expose :id, as: :order_id
        expose :status
        expose :status_type
        expose :shipping_type
        expose :order_type
        expose :total_price, as: :price
        expose :order_type
        expose :warehouse_name
        expose :distributor_name
        # expose :po_no
        expose :created_at, as: :date
        expose :prev_status
        expose :business_type

        def status
          object&.status&.admin_order_status&.humanize
        end

        def status_type
          object&.status&.order_type
        end

        def warehouse_name
          object&.warehouse&.name
        end

        def distributor_name
          object&.distributor&.name
        end

        def prev_status
          if object.customer_order_status_changes.count > 1
            object.prev_status&.order_status&.admin_order_status&.humanize
          else
            if object.status === OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment]) or object.status === OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled])
              'Order placed'
            else
              object.prev_status&.order_status&.admin_order_status&.humanize
            end
          end
        end

        def shipping_type
          object.shipping_type.titleize
        end
      end
    end
  end
end
