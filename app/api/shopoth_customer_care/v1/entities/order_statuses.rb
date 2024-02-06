module ShopothCustomerCare
  module V1
    module Entities
      class OrderStatuses < Grape::Entity
        expose :id
        expose :order_type
        expose :system_order_status
        expose :customer_order_status
        expose :admin_order_status
        expose :sales_representative_order_status
        expose :partner_order_status

        def order_type
          object.order_type&.humanize
        end

        def system_order_status
          object.system_order_status&.humanize
        end

        def customer_order_status
          object.customer_order_status&.humanize
        end

        def admin_order_status
          object.admin_order_status&.humanize
        end

        def sales_representative_order_status
          object.sales_representative_order_status&.humanize
        end

        def partner_order_status
          object.partner_order_status&.humanize
        end

      end
    end
  end
end
