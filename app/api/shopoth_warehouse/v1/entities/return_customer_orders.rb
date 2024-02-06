module ShopothWarehouse
  module V1
    module Entities
      class ReturnCustomerOrders < Grape::Entity
        expose :id
        expose :customer_order_id, as: :order_id
        expose :formatted_order_id
        expose :partner
        expose :rider_id
        expose :return_status
        expose :return_type
        expose :reason
        expose :description
        expose :qr_code
        expose :route
        expose :shopoth_line_items
        expose :created_by

        def shopoth_line_items
          line_items = object.customer_order.shopoth_line_items
          ShopothWarehouse::V1::Entities::ShopothLineItemList.represent(line_items)
        end

        def formatted_order_id
          object&.customer_order&.backend_id
        end

        def partner
          partner = object&.customer_order&.partner
          {
            name: partner&.name,
            phone_no: partner&.phone,
            shop_name: partner&.name,
            retailer_code: partner&.retailer_code,
            address: "#{partner&.area&.to_s} #{partner&.territory&.to_s}",
          }
        end

        def route
          route = object&.customer_order&.partner&.route
          {
            name: route&.title,
            bn_name: route&.bn_title,
            phone: route&.phone,
            cash_amount: route&.cash_amount,
            digital_amount: route&.digital_amount,
            sr_name: route&.sr_name,
          }
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
