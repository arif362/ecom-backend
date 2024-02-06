# frozen_string_literal: true

module ShopothCustomerCare
  module V1
    module Entities
      module AggregateReturn
        class AggregateReturns < Grape::Entity
          expose :id
          expose :customer_order_id
          expose :refunded
          expose :sub_total
          expose :grand_total
          expose :order_type
          expose :customer_name
          expose :pick_up_charge
          expose :warehouse_id
          expose :warehouse_name
          expose :created_at, as: :requested_on
          expose :return_items_count

          def order_type
            object.customer_order.order_type
          end

          def customer_name
            object.customer_order.customer.name
          end

          def warehouse_name
            object&.warehouse&.name
          end

          def return_items_count
            object.return_customer_orders.count
          end
        end
      end
    end
  end
end
