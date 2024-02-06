module ShopothCustomerCare
  module V1
    module Entities
      module Customers
        class Details < Grape::Entity
          expose :id
          expose :full_name, as: :name
          expose :created_at, as: :joined_at
          expose :email
          expose :phone
          expose :status
          expose :addresses
          expose :customer_orders, using: ShopothCustomerCare::V1::Entities::CustomerOrders::List
          expose :return_customer_orders
          expose :coupons

          def addresses
            object.addresses.map do |address|
              {
                address_line: address&.address_line,
                area: address&.area&.name,
                thana: address&.thana&.name,
                district: address&.district&.name,
                post_code: address&.zip_code,
              }
            end
          end

          def return_customer_orders
            return_orders = []
            object.customer_orders&.each do |order|
              return_orders << get_returned_items(order.return_customer_orders)
            end
            return_orders.flatten.compact
          end

          def get_returned_items(return_customer_orders)
            result = []
            return_customer_orders.each do |return_order|
              result << {
                id: return_order.id,
                date: return_order.created_at,
                item_title: return_order.shopoth_line_item&.variant&.product&.title,
                price: return_order.shopoth_line_item&.price,
                return_type: return_order.return_type,
                return_status: return_order.return_status,
              }
            end
            result
          end

          def coupons
            coupons = object.coupons.where(promotion_id: nil)
            ShopothCustomerCare::V1::Entities::Customers::Coupons.represent(coupons)
          end
        end
      end
    end
  end
end
