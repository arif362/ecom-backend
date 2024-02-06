module ShopothWarehouse
  module V1
    module Entities
      class WarehouseBalanceDetails < Grape::Entity
        expose :name
        expose :bn_name
        expose :email
        expose :phone
        expose :warehouse_cash_collected
        # expose :warehouse_wallet_collected
        expose :warehouse_collectable
        expose :total_returned_request
        expose :total_return_collectable

        def warehouse_cash_collected
          object&.collected_cash_from_routes
        end

        # def warehouse_wallet_collected
        #   object&.wallet&.currency_amount
        # end

        def warehouse_collectable
          collectable_cash = 0.0
          # collectable_wallet = 0.0
          object&.routes&.each do |route|
            collectable_cash += route.cash_amount
            # collectable_wallet += route.wallet.currency_amount
          end
          object&.riders&.each do |rider|
            collectable_cash += rider.cash_collected
            # collectable_wallet += rider.wallet.currency_amount
          end
          {
            cash: collectable_cash.round(2),
            # wallet: collectable_wallet.round(2),
          }
        end

        def total_returned_request
          object&.return_count.to_i
        end

        def total_return_collectable
          partner_return_count = object&.partners&.map do |partner|
            partner&.return_customer_orders&.where(return_status: 'in_transit').count
          end.sum
          rider_return_count = object&.riders&.map do |rider|
            rider&.return_customer_orders&.where(return_status: 'in_transit').count
          end.sum
          partner_return_count + rider_return_count
        end
      end
    end
  end
end
