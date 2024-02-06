module ShopothPartner
  module V1
    module Entities
      class PartnerOrderHistories < Grape::Entity
        expose :id, as: :order_id
        expose :customer_name
        expose :phone
        expose :cart_total_price, as: :amount
        expose :order_type

        def customer_name
          object&.customer&.name
        end

        def phone
          object&.customer&.phone
        end
      end
    end
  end
end
