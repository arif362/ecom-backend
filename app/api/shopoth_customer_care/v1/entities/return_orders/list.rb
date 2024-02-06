module ShopothCustomerCare
  module V1
    module Entities
      module ReturnOrders
        class List < Grape::Entity
          expose :id
          expose :backend_id
          expose :order_no
          expose :customer_id
          expose :customer_name
          expose :shop_name
          expose :created_at
          expose :phone
          expose :preferred_delivery_date
          expose :price
          expose :return_type
          expose :return_status
          expose :customer_order_type
          expose :initiated_by

          def order_no
            object.customer_order&.number
          end

          def price
            object.customer_order.cart_total_price
          end

          def customer_id
            object.customer_order&.customer&.id
          end

          def customer_name
            object.customer_order.customer.name
          end

          def shop_name
            object.customer_order&.partner&.name
          end

          def product_count
            object.customer_order&.item_count
          end

          def phone
            object.customer_order&.partner&.phone
          end

          def customer_order_type
            object.customer_order.order_type
          end

          def initiated_by
            if object.return_orderable_type == 'CustomerCareAgent'
              'Customer Care'
            else
              object.return_orderable_type
            end
          end
        end
      end
    end
  end
end
