# frozen_string_literal: true

module Ecommerce
  module V1
    module Entities
      class CustomerOrders < Grape::Entity
        expose :order_id
        expose :created_at, as: :ordered_on
        expose :delivered_on
        expose :status
        expose :status_key
        expose :bn_status
        expose :vat_shipping_charge
        expose :total
        expose :returnable?, as: :is_returnable
        expose :returnable_date

        def order_id
          object.frontend_id
        end

        def delivered_on
          case object.shipping_type
          when 'home_delivery', 'pick_up_point'
            (object.created_at + 72.hours)
          when 'express_delivery'
            (object.created_at + 3.hours)
          else
            object.created_at
          end
        end

        def status_key
          object.status&.order_type
        end

        def status
          object.status&.customer_order_status
        end

        def bn_status
          object.status&.bn_customer_order_status
        end

        def total
          object.total_price&.ceil
        end

        def returnable_date
          if object.status.completed? || object.status.partially_returned?
            object.completed_order_status_date + 7.day
          else
            ''
          end
        end
      end
    end
  end
end
