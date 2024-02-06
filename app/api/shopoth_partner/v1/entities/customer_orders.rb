module ShopothPartner
  module V1
    module Entities
      class CustomerOrders < Grape::Entity
        expose :id, as: :order_id
        expose :customer_id
        expose :total_price

        def total_price
          object.total_price.ceil
        end
      end
    end
  end
end
