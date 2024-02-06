module ShopothCustomerCare
  module V1
    module Entities
      class OrderDetails < Grape::Entity
        expose :id, as: :order_id
        expose :shipping_address
        expose :billing_address
        expose :order_type
        expose :pay_type
        expose :shopoth_line_items_total_price, as: :sub_total
        expose :shipping_charge
        expose :total_price, as: :grand_total
        expose :total_discount_amount
        expose :payments
        expose :created_at, as: :order_at
        expose :rider
        expose :shopoth_line_items, using: ShopothCustomerCare::V1::Entities::LineItems
        expose :customer
        expose :status
        expose :status_key
        expose :pay_status
        expose :shipping_type
        expose :partner
        expose :is_customer_paid
        expose :receiver_info
        expose :vat_shipping_charge

        def partner
          partner = object.partner
          return {} unless partner.present?

          {
            name: partner.name,
            phone: partner.phone,
            email: partner.email,
            route_id: partner.route_id,
            area: partner.area,
            section: section,
          }
        end

        def rider
          rider = object.rider
          return {} unless rider.present?

          {
            id: rider.id,
            name: rider.name,
            phone: rider.phone,
            email: rider.email,
          }
        end

        def shipping_address
          shipping_address = object.shipping_address
          return {} unless shipping_address.present?

          {
            area: shipping_address.area&.name,
            thana: shipping_address.thana&.name,
            district: shipping_address.district&.name,
            phone: shipping_address.phone,
            address_line: shipping_address.address_line,
          }
        end

        def billing_address
          billing_address = object.billing_address
          return {} unless billing_address.present?

          {
            area: billing_address.area&.name,
            thana: billing_address.thana&.name,
            district: billing_address.district&.name,
            phone: billing_address.phone,
            address_line: billing_address.address_line,
          }
        end

        def customer
          customer = object&.customer
          {
            name: customer.full_name,
            phone: customer.phone,
            email: customer.email,
          }
        end

        def status
          object&.status&.admin_order_status
        end

        def status_key
          object&.status&.status_key
        end

        def shipping_type
          object.shipping_type&.humanize
        end

        def pay_type
          object.pay_type&.humanize
        end

        def receiver_info
          {
            name: object&.name,
            phone: object&.phone,
          }
        end

        def section
          schedule = object&.partner&.schedule
          case schedule
          when 'sat_mon_wed'
            'A'
          when 'sun_tues_thurs'
            'B'
          else
            'D'
          end
        end

        def payments
          []
        end
      end
    end
  end
end
