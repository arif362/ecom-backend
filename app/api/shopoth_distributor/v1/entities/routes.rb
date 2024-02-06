module ShopothDistributor
  module V1
    module Entities
      class Routes < Grape::Entity
        expose :id
        expose :title
        expose :sr_name
        expose :sr_point
        expose :bn_title
        expose :phone
        expose :cash_amount
        expose :total_order
        expose :due
        expose :distributor_name
        expose :distributor_bn_name

        def total_order
          total_order = 0
          completed_order = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          total_order += object&.customer_orders&.where(status: completed_order, pay_status: :customer_paid)&.count
          total_order += object&.customer_orders&.where(status: completed_order, pay_status: :partner_paid)&.count
          total_order
        end

        def due
          object&.customer_orders&.
            where(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]),
                  pay_status: :customer_paid)&.map(&:total_price)&.sum
        end

        def distributor
          object&.distributor
        end

        def distributor_name
          distributor&.name
        end

        def distributor_bn_name
          distributor&.bn_name
        end
      end
    end
  end
end
