module ShopothWarehouse
  module V1
    module Entities
      class ReconciliationRiders < Grape::Entity
        expose :id
        expose :name
        expose :phone
        expose :email
        expose :warehouse_id
        expose :distributor_name
        expose :collected
        expose :total_order
        expose :prepaid_order_count

        def distributor_name
          object.distributor&.name || ''
        end

        def customer_orders
          @customer_orders ||= object.customer_orders
        end
      end
    end
  end
end
