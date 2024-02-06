module ShopothWarehouse
  module V1
    module Entities
      class CustomerOrders < Grape::Entity
        expose :id
        expose :order_status
        expose :status_type
        expose :shipping_type
        expose :pay_status
        expose :is_customer_paid
        expose :order_type
        expose :total_price
        expose :warehouse_name
        expose :distributor_name
        expose :business_type

        def order_status
          status&.admin_order_status&.humanize || ''
        end

        def status_type
          status&.order_type || ''
        end

        def warehouse_name
          object.warehouse&.name || ''
        end

        def status
          @status ||= object.status
        end

        def distributor_name
          object.distributor.name
        end
      end
    end
  end
end
