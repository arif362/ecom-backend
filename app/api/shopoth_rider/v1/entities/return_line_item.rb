module ShopothRider
  module V1
    module Entities
      class ReturnLineItem < Grape::Entity
        expose :id, as: :return_id
        expose :return_date
        expose :order_id
        expose :customer_name
        expose :customer_phone
        expose :return_status
        expose :reason
        expose :description
        expose :items

        def order_id
          object&.customer_order&.id
        end

        def return_id
          object&.id
        end

        def return_date
          object&.created_at
        end

        def return_status
          object&.return_status
        end

        def customer_name
          customer = object&.customer_order&.customer
          customer&.name
        end

        def customer_phone
          object&.customer_order&.customer&.phone
        end

        def items
          line_items = []
          if object&.return_type == 'packed'
            object&.customer_order&.shopoth_line_items.each do |item|
              line_items << item
            end
          else
            line_items << object&.shopoth_line_item
          end
          ShopothRider::V1::Entities::ShopothLineItemList.represent(line_items)
        end
      end
    end
  end
end
