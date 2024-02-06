module ShopothCustomerCare
  module V1
    module Entities
      module Customers
        class Coupons < Grape::Entity
          expose :code
          expose :discount_amount
          expose :is_used
        end
      end
    end
  end
end
