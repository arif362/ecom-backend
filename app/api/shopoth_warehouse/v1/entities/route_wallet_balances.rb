module ShopothWarehouse
  module V1
    module Entities
      class RouteWalletBalances < Grape::Entity
        expose :id
        expose :cash_amount
        # expose :digital_amount

        def digital_amount
          object&.wallet&.currency_amount
        end
      end
    end
  end
end
