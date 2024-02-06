module ShopothCustomerCare
  module V1
    module Entities
      module CustomerOrders
        class List < Grape::Entity
          expose :id, as: :order_id
          expose :backend_id, as: :order_no
          expose :customer_id
          expose :customer_name
          expose :mobile
          expose :location
          expose :order_type
          expose :shipping_type
          expose :pay_type
          expose :status
          expose :preferred_delivery_date
          expose :total_price, as: :total_amount
          expose :created_at, as: :date

          def customer_name
            customer&.name
          end

          def mobile
            customer&.phone
          end

          def location
            object&.shipping_address&.area&.name
          end

          def status
            object.status&.admin_order_status&.humanize
          end

          def customer
            @customer ||= User.unscoped.find_by(id: object.customer_id)
          end

          def shipping_type
            object.shipping_type.titleize
          end
        end
      end
    end
  end
end
