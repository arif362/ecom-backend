# frozen_string_literal: true

module ShopothDistributor
  module V1
    module Entities
      class AggrDetails < Grape::Entity
        expose :id
        expose :customer_order_id
        expose :refunded
        expose :sub_total
        expose :grand_total
        expose :order_type
        expose :pick_up_type
        expose :pick_up_charge
        expose :vat_shipping_charge
        expose :coupon_code
        expose :reschedulable
        expose :reschedule_date
        expose :warehouse_id
        expose :warehouse_name
        expose :return_items_count
        expose :created_at, as: :requested_on
        expose :customer
        expose :receiver_info
        expose :pick_address
        expose :rider_info
        expose :partner_info
        expose :route_info
        expose :return_orders
        expose :return_quantity

        def return_quantity
          object.return_customer_orders.sum(:quantity)
        end

        def order_type
          object.customer_order.order_type
        end

        def pick_up_type
          object.return_customer_orders.first.form_of_return
        end

        def customer
          customer = object.customer_order.customer
          {
            customer_id: customer.id,
            customer_name: customer.name,
            customer_phone: customer.phone,
          }
        end

        def receiver_info
          {
            phone: object.customer_order.phone,
            name: object.customer_order.name,
          }
        end

        def warehouse_name
          object&.warehouse&.name
        end

        def return_items_count
          object.return_customer_orders.count
        end

        def pick_address
          if object.return_customer_orders.first.from_home?
            home_address
          elsif object.return_customer_orders.first.to_partner?
            partner_address
          end
        end

        def home_address
          return {} if object.address.nil?

          {
            district_id: object.address.district_id,
            district_name: object.address.district.name,
            thana_id: object.address.thana_id,
            thana_name: object.address.thana&.name,
            area_id: object.address.area_id,
            area_name: object.address.area.name,
            address_line: object.address.address_line,
          }
        end

        def partner_address
          partner = object.return_customer_orders.first.partner
          return {} if partner.address.nil?

          {
            district_id: partner.address.district_id,
            district_name: partner.address.district&.name,
            thana_id: partner.address.thana_id,
            thana_name: partner.address.thana&.name,
            area_id: partner.address.area_id,
            area_name: partner.address.area&.name,
            address_line: partner.address.address_line,
          }
        end

        def rider_info
          return {} if object.rider.nil?

          {
            rider_id: object.rider.id,
            rider_name: object.rider.name,
            rider_phone: object.rider.phone,
          }
        end

        def partner_info
          return {} unless partner.present?

          {
            partner_id: partner.id,
            partner_name: partner.name,
            partner_phone: partner.phone,
          }
        end

        def route_info
          return {} unless partner.present?

          {
            route_id: partner.route.id,
            route_name: partner.route.title,
            route_phone: partner.route.phone,
          }
        end

        def partner
          object.return_customer_orders.first.partner
        end

        def return_orders
          line_items = object.return_customer_orders.order(id: :asc)
          ShopothWarehouse::V1::Entities::AggrReturnItems.represent(line_items)
        end

        def reschedulable
          if object.return_customer_orders.from_home.present? && object.refunded == false
            true
          else
            false
          end
        end

        def coupon_code
          object&.coupon&.code
        end
      end
    end
  end
end
