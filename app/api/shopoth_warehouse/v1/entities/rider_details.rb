module ShopothWarehouse
  module V1
    module Entities
      class RidersDetails < Grape::Entity
        expose :id
        expose :name
        expose :rider_details
        expose :return_details

        def rider_details
          status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          customer_orders = object.customer_orders.where(status: status)
          total_price = customer_orders.map(&:total_price)&.sum
          collected_by_rider = customer_orders.where(pay_status: :customer_paid).map(&:total_price)&.sum
          collected_by_dh = customer_orders.where(pay_status: :dh_received).map(&:total_price)&.sum
          {
            total_price: total_price,
            collected_by_rider: collected_by_rider,
            collected_by_dh: collected_by_dh,
          }
        end

        def return_details
          no_of_sku = 0
          collected_sku_by_rider = 0
          completed = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          # # cancelled = OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled])
          object.return_customer_orders.each do |returned_order|
            no_of_sku += 1 if returned_order.customer_order.status == completed &&
                              returned_order.from_home? && returned_order.unpacked?
            if returned_order.customer_order.status == completed && returned_order.from_home? &&
               returned_order.unpacked? && returned_order.in_transit?
              collected_sku_by_rider += 1
            end
          end
          {
            no_of_sku: no_of_sku,
            collected_sku_by_rider: collected_sku_by_rider,
          }
        end
      end
    end
  end
end
