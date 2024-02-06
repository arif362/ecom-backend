module ShopothWarehouse
  module V1
    module Entities
      class Riders < Grape::Entity
        expose :id
        expose :name
        expose :phone
        expose :email
        expose :warehouse_id
        expose :distributor_id
        expose :distributor_name
        expose :cash_collected
        expose :total_order
        expose :created_by

        def distributor_name
          object.distributor&.name || ''
        end

        def total_order
          status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          object.customer_orders.where(status: status, is_customer_paid: true).size
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
