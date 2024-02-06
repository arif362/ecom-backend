module ShopothWarehouse
  module V1
    module Entities
      class ReturnOrders < Grape::Entity
        expose :id
        expose :customer_order_id
        expose :partner_id
        expose :rider_id
        expose :return_status
        expose :return_type
        expose :business_type
        expose :reason
        expose :description
        expose :qr_code
        expose :product_count
        expose :phone
        expose :shop_name
        expose :quantity
        expose :return_orderable_type, as: :initiated_by

        def shop_name
          object.customer_order&.partner&.name
        end

        def business_type
          object.customer_order&.business_type
        end

        def product_count
          object.customer_order&.item_count
        end

        def phone
          object.customer_order&.partner&.phone
        end
      end
    end
  end
end
