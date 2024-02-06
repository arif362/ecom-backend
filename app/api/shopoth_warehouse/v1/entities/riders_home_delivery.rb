module ShopothWarehouse
  module V1
    module Entities
      class RidersHomeDelivery < Grape::Entity
        expose :id, as: :order_id
        expose :number, as: :phone_number
        expose :total_price, as: :amount
        expose :order_type
        expose :pay_type, as: :payment_type
        expose :shipping_address, as: :address
        expose :status
        expose :name, as: :customer_name

        def number
          object.customer.phone
        end

        def name
          object&.customer&.name
        end

        def status
          object.status.order_type
        end

        def shipping_address
          shipping = Address.find(object.shipping_address_id)
          shipping.address_line
        end
      end
    end
  end
end
