module ShopothPartner
  module V1
    module Entities
      class BnOrderDetails < Grape::Entity
        expose :id, as: :order_id
        expose :created_at, as: :order_date
        expose :customer
        expose :order_type
        expose :order_status
        expose :shopoth_line_items, using: ShopothPartner::V1::Entities::BnOrdersLineItems
        expose :total_price
        expose :vat_shipping_charge
        expose :business_type

        def customer
          {
            name: object&.customer&.name,
            phone: object&.customer&.phone.to_s.to_bn,
          }
        end

        def bn_order_id
          object.id.to_s.to_bn
        end

        def order_type
          type = object.order_type
          I18n.t("order_type.#{type}")
        end

        def order_status
          status = object&.status&.order_type
          I18n.t("order_status.#{status}")
        end

        def total_price
          {
            consumer_price: object.total_price.to_s.to_bn,
          }
        end

        def created_at
          object.created_at.to_s.to_bn
        end
      end
    end
  end
end
