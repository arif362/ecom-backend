module ShopothDistributor
  module V1
    module Entities
      class CustomerOrder < Grape::Entity
        expose :id, as: :order_id
        expose :status
        expose :status_type
        expose :shipping_type
        expose :order_type
        expose :total_price, as: :price
        expose :order_type
        expose :warehouse_name
        expose :business_type
        expose :created_at, as: :date

        def status
          object.status.admin_order_status.titleize
        end

        def shipping_type
          object.shipping_type.titleize
        end

        def status_type
          object.status.order_type.titleize
        end

        def warehouse_name
          object&.warehouse&.name
        end
      end
    end
  end
end
