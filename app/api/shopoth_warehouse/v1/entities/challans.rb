module ShopothWarehouse
  module V1
    module Entities
      class Challans < Grape::Entity
        expose :id
        expose :status
        expose :distributor
        expose :fulfillment_center
        expose :challan_line_items
        expose :created_by
        expose :created_at

        def challan_line_items
          return if options[:list]
          object.challan_line_items.map do |cli|
            {
              id: cli.id,
              status: cli.status,
              order: {
                id: cli.customer_order.id,
                status: cli.customer_order.status.order_type.titleize,
                pay_type: cli.customer_order.pay_type.titleize,
                is_customer_paid: cli.customer_order.is_customer_paid,
                shipping_type: cli.customer_order.shipping_type.titleize,
                total_price: cli.customer_order.total_price,
              }
            }
          end
        end

        def fulfillment_center
          object.warehouse&.as_json(only: %i(id name bn_name phone)) || {}
        end

        def distributor
          object.distributor&.as_json(only: %i(id name bn_name phone)) || {}
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
