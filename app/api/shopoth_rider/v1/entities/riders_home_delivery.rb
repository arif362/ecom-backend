module ShopothRider
  module V1
    module Entities
      class RidersHomeDelivery < Grape::Entity
        expose :id, as: :order_id
        expose :number, as: :phone_number
        expose :total_price, as: :amount
        expose :shipping_charge
        expose :total_discount_amount
        expose :order_type
        expose :pay_type, as: :payment_type
        expose :shipping_address, as: :address
        expose :status
        expose :on_hold
        expose :name, as: :customer_name
        expose :expected_delivery_time

        def expected_delivery_time
          due_date_time = object.created_at + 72.hours
          due_date_time.to_datetime.strftime('%Q')
        end

        def number
          object&.customer&.phone
        end

        def name
          object&.customer&.name
        end

        def status
          object&.status&.order_type
        end

        def shipping_address
          shipping = Address.find_by(id: object.shipping_address_id)
          shipping.address_line if shipping.present?
        end

        def on_hold
          object&.status&.order_type == 'on_hold'
        end
      end
    end
  end
end
