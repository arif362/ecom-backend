# frozen_string_literal: true

module ShopothDistributor
  module V1
    module Entities
      class ReturnOrders < Grape::Entity
        expose :id
        expose :customer_order_number
        expose :customer_id
        expose :customer_name
        expose :shop_name
        expose :created_at
        expose :phone
        expose :price
        expose :return_type
        expose :return_status
        expose :customer_order_type
        expose :order_id
        expose :initiated_by

        def customer_order_type
          customer_order&.order_type
        end

        def customer_order_number
          customer_order&.number
        end

        def price
          object.customer_order.cart_total_price
        end

        def customer_id
          customer&.id
        end

        def customer_name
          object.customer_order.customer.name
        end

        def shop_name
          customer_order&.partner&.name
        end

        def product_count
          customer_order&.item_count
        end

        def phone
          customer_order&.partner&.phone
        end

        def order_id
          customer_order.id
        end

        def customer_order
          @customer_order ||= object&.customer_order
        end

        def customer
          @customer ||= customer_order&.customer
        end

        def initiated_by
          if object.return_orderable_type == 'CustomerCareAgent'
            'Customer Care'
          else
            object.return_orderable_type
          end
        end

        def return_type
          object.return_type.titleize
        end

        def return_status
          object.return_status.titleize
        end
      end
    end
  end
end
