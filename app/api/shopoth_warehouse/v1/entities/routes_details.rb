module ShopothWarehouse
  module V1
    module Entities
      class RoutesDetails < Grape::Entity
        expose :id
        expose :title
        expose :sr_details
        expose :return_details

        def sr_details
          status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          customer_orders = object.customer_orders.where(status: status)
          total_price = customer_orders.map(&:total_price)&.sum
          collected_by_sr = customer_orders.where(pay_status: :partner_paid).map(&:total_price)&.sum
          collected_by_dh = customer_orders.where(pay_status: :dh_received).map(&:total_price)&.sum
          {
            total_price: total_price,
            collected_by_sr: collected_by_sr,
            collected_by_dh: collected_by_dh,
          }
        end

        def return_details
          no_of_sku = 0
          collected_sku_by_sr = 0
          no_of_returned_orders = 0
          collected_orders_by_sr = 0
          completed = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          # cancelled = OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled])
          object.return_customer_orders.each do |returned_order|
            no_of_sku += 1 if returned_order.customer_order.status == completed
            if returned_order.customer_order.status == completed && returned_order.in_transit?
              collected_sku_by_sr += 1
            end
            no_of_returned_orders += 1 if returned_order.to_partner? && returned_order.packed?
            collected_orders_by_sr += 1 if returned_order.to_partner? && returned_order.packed? &&
                                           returned_order.in_transit?
          end
          {
            no_of_sku: no_of_sku,
            collected_sku_by_sr: collected_sku_by_sr,
            no_of_returned_orders: no_of_returned_orders,
            collected_returned_orders_by_sr: collected_orders_by_sr,
          }
        end
      end
    end
  end
end
