module ShopothWarehouse
  module V1
    module Entities
      class PaymentListHistory < Grape::Entity
        expose :id, as: :order_id
        expose :pay_status, as: :payment_status
        expose :order_type
        expose :business_type
        expose :shop_name
        expose :phone
        expose :completed_at, as: :delivery_date
        expose :amount

        def payment_status
          object.status.sales_representative_order_status
        end

        def shop_name
          object.partner.name
        end

        def phone
          object.partner.phone
        end

        def amount
          partner_commission = 0
          # partner_commission = object.induced? ? object.partner_commission : 0
          object.total_price - partner_commission
        end
      end
    end
  end
end
