# frozen_string_literal: true

module Ecommerce
  module V1
    module Entities
      class CustomerOrderDetails < Grape::Entity
        expose :id, as: :order_id
        expose :shipping_charge
        expose :total_discount_amount
        expose :shipping_type
        expose :order_type
        expose :pay_type
        expose :trx_id
        expose :cart_total_price, as: :total_price
        expose :vat_shipping_charge
        expose :total_price, as: :total_payable
        expose :partner_id
        expose :partner_name
        expose :partner_code
        expose :created_at
        expose :completed_at
        expose :name, as: :recipient_name
        expose :phone, as: :recipient_phone
        expose :customer_name
        expose :customer_phone
        expose :returnable?, as: :is_returnable
        expose :return_charge
        expose :returnable_date
        expose :status
        expose :status_key
        expose :bn_status
        expose :return_vat_shipping_charge
        expose :shipping_address
        expose :shopoth_line_items
        expose :tenure

        def trx_id
          object.payments&.successful&.first&.payment_reference_id || ''
        end

        def partner_name
          partner&.name || ''
        end

        def partner_code
          partner&.partner_code || ''
        end

        def partner
          @partner ||= object.partner
        end

        def customer
          @customer ||= object.customer
        end

        def customer_name
          customer&.full_name || ''
        end

        def customer_phone
          customer&.phone || ''
        end

        def status_key
          order_status&.order_type
        end

        def status
          object.status&.customer_order_status
        end

        def bn_status
          I18n.locale == :bn ? I18n.t("order_status.#{object.status&.order_type}") : ''
        end

        def order_status
          @order_status = object.status
        end

        def return_charge
          if object.home_delivery? || object.express_delivery?
            Configuration.return_pick_up_charge('from_home')
          else
            0.0
          end
        end

        def returnable_date
          if object.status.completed? || object.status.partially_returned?
            object.completed_order_status_date + 7.day
          else
            ''
          end
        end

        def shipping_address
          if object.home_delivery? || object.express_delivery?
            Ecommerce::V1::Entities::Address.represent(object&.shipping_address)
          else
            Ecommerce::V1::Entities::Address.represent(object.partner&.address)
          end
        end

        def shopoth_line_items
          Ecommerce::V1::Entities::ShopothLineItems.represent(object.shopoth_line_items)
        end

        def return_vat_shipping_charge
          return 0 if object.pick_up_point?

          (Configuration.return_pick_up_charge('from_home') * 0.15).round
        end
      end
    end
  end
end
