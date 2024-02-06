module ShopothDistributor
  module V1
    module Entities
      class ReturnChallans < Grape::Entity
        expose :id
        expose :status
        expose :distributor
        expose :fulfillment_center
        expose :customer_orders
        expose :return_customer_orders
        expose :created_by_id
        expose :created_at

        def customer_orders
          return if options[:list]
          object.customer_orders.map do |co|
            {
              id: co.id,
              return_challan_line_item_status: co.return_challan_line_item.status,
              status: co.status.order_type,
              pay_type: co.pay_type,
              is_customer_paid: co.is_customer_paid,
              shipping_type: co.shipping_type,
              total_price: co.total_price,
            }
          end
        end

        def return_customer_orders
          return if options[:list]
          object.return_customer_orders.map do |rco|
            {
              id: rco.id,
              return_challan_line_item_status: rco.return_challan_line_item.status,
              return_status: rco.return_status,
              return_type: rco.return_type,
              sub_total: rco.return_type == 'packed' ? rco.customer_order.total_price : rco.sub_total,
            }
          end
        end

        def fulfillment_center
          object.warehouse&.as_json(only: %i(id name bn_name phone)) || {}
        end

        def distributor
          object.distributor&.as_json(only: %i(id name bn_name phone)) || {}
        end

        def created_by_id
          object.created_by&.id
        end
      end
    end
  end
end
