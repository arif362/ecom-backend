module ShopothWarehouse
  module V1
    module Entities
      class PaymentDetails < Grape::Entity
        expose :id
        expose :status
        expose :currency_amount
      end
    end
  end
end

