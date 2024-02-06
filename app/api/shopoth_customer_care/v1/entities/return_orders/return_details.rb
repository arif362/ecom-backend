module ShopothCustomerCare
  module V1
    module Entities
      module ReturnOrders
        class ReturnDetails < Grape::Entity
          expose :id
          expose :order_no
          expose :customer_name
          expose :shop_name
          expose :created_at
          expose :phone
          expose :price
          expose :return_type
          expose :return_status
          # expose :customer_order, using: ShopothCustomerCare::V1::Entities::CustomerOrders::Details

          def order_no
            object.customer_order&.number
          end

          def price
            object.shopoth_line_item&.price
          end

          def customer_name
            object.customer_order&.customer&.name
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
        end
      end
    end
  end
end
