module ShopothWarehouse
  module V1
    module Entities
      class ReturnOrderDetailsWithLineItems < Grape::Entity
        expose :id
        expose :return_order_id
        expose :customer_order_id
        expose :order_id
        expose :price
        expose :return_status
        expose :partner_information
        expose :route_information
        expose :rider_information
        expose :return_type
        expose :delivered_to_sr_at
        expose :created_at, as: :date
        expose :reason
        expose :description
        expose :qr_code
        expose :preferred_delivery_date
        expose :cancellation_reason
        expose :form_of_return
        expose :warehouse_id
        expose :product_count
        expose :line_items
        expose :receiver_type
        expose :customer_information
        expose :warehouse_information
        expose :sub_total
        expose :shipping_charge
        expose :grand_total

        def return_order_id
          object&.backend_id
        end

        def order_id
          customer_order&.backend_id
        end

        def price
          customer_order&.total_price
        end

        def route_information
          if object&.partner&.route.present?
            route = object.partner&.route
            {
              id: route&.id,
              name: route&.title,
              phone: route&.phone,
            }
          else
            {}
          end
        end

        def rider_information
          if object&.rider.present?
            rider = object&.rider
            {
              id: rider&.id,
              name: rider&.name,
              phone: rider&.phone,
            }
          else
            {}
          end
        end

        def partner_information
          if object&.partner.present?
            partner = object&.partner
            { id: partner&.id,
              name: partner&.name,
              phone: partner&.phone,
              email: partner&.email,
              area: partner&.area, }
          else
            {}
          end
        end

        def product_count
          customer_order&.item_count
        end

        def line_items
          line_items = customer_order&.shopoth_line_items
          ShopothWarehouse::V1::Entities::ReturnedLineItems.represent(line_items)
        end

        def receiver_type
          receiver = 'Route'
          receiver = 'Rider' if object.rider_id.present?
          receiver
        end

        def customer_information
          {
            id: customer&.id,
            name: customer&.name,
            phone: customer&.phone,
            email: customer&.email,
          }
        end

        def warehouse_information
          {
            name: warehouse&.name,
            phone: warehouse&.phone,
          }
        end

        def sub_total
          customer_order.shopoth_line_items.sum(&:sub_total)
        end

        def shipping_charge
          customer_order&.shipping_charge
        end

        def grand_total
          customer_order.total_price
        end

        def customer_order
          @customer_order ||= object&.customer_order
        end

        def customer
          @customer ||= customer_order&.customer
        end

        def warehouse
          @warehouse ||= object&.warehouse
        end
      end
    end
  end
end
