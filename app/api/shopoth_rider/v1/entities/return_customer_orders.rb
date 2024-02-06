module ShopothRider
  module V1
    module Entities
      class ReturnCustomerOrders < Grape::Entity
        expose :id, as: :return_item_id
        expose :return_id
        expose :order_id
        expose :customer_name
        expose :customer_phone
        expose :shipping_address
        expose :return_status
        expose :return_type
        expose :return_orderable_type, as: :initiated_by

        def return_id
          object&.id
        end

        def order_id
          object&.customer_order&.id
        end

        def customer_name
          customer = object&.customer_order&.customer
          customer.name
        end

        def customer_phone
          object&.customer_order&.customer&.phone
        end

        def shipping_address
          address = object&.customer_order&.shipping_address
          return {} unless address.present?

          {
              area: address.area.name,
              thana: address.thana.name,
              district: address.district.name,
              phone: address.phone,
          }
        end

        def return_status
          object&.return_status
        end

        def return_type
          object&.return_type
        end
      end
    end
  end
end
