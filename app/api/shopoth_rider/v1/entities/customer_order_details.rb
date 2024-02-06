module ShopothRider
  module V1
    module Entities
      class CustomerOrderDetails < Grape::Entity
        expose :id, as: :order_id
        expose :shipping_address
        expose :billing_address
        expose :order_type
        expose :pay_type
        expose :cart_total_price, as: :sub_total
        expose :shipping_charge
        expose :total_price, as: :grand_total
        expose :total_discount_amount
        expose :created_at, as: :order_at
        expose :shopoth_line_items, using: ShopothWarehouse::V1::Entities::ShopothLineItemList
        expose :customer
        expose :status
        expose :partner
        expose :vat_shipping_charge

        def partner
          partner = object&.partner
          return {} unless partner.present?

          {
            name: partner.name,
            phone: partner.phone,
            email: partner.email,
            route_id: partner.route_id,
            area: partner.area,
          }
        end

        def shipping_address
          address = object&.shipping_address
          return {} unless address.present?

          {
            area: address.area.name,
            thana: address.thana.name,
            district: address.district.name,
            phone: address.phone,
          }
        end

        def billing_address
          billing_address = object&.billing_address
          return {} unless billing_address.present?

          {
            area: billing_address.area.name,
            thana: billing_address.thana.name,
            district: billing_address.district.name,
            phone: billing_address.phone,
          }
        end

        def customer
          customer = object&.customer
          return {} unless customer.present?

          {
            name: customer&.name,
            phone: customer.phone,
            email: customer.email,
          }
        end

        def status
          object.status.order_type
        end
      end
    end
  end
end
