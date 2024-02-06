module ShopothWarehouse
  module V1
    module Entities
      class Routes < Grape::Entity
        expose :id
        expose :title
        expose :sr_name
        expose :sr_point
        expose :bn_title
        expose :phone
        expose :cash_amount
        # expose :wallet_balance
        expose :total_order
        expose :due
        expose :distributor_id
        expose :distributor_name
        expose :distributor_bn_name

        # def wallet_balance
        #   object.create_wallet(currency_amount: 0.0, currency_type: 'Tk.') if object.wallet.nil?
        #   object&.wallet&.currency_amount
        # end

        def total_order
          total_order = 0
          total_order += object&.customer_orders&.where(order_status_id: 8, pay_status: :customer_paid)&.count
          total_order += object&.customer_orders&.where(order_status_id: 8, pay_status: :partner_paid)&.count
          total_order
        end

        def due
          object&.customer_orders&.where(order_status_id: 8,
                                         pay_status: :customer_paid)&.map(&:total_price)&.sum
        end

        def distributor
          object&.distributor
        end

        def distributor_name
          distributor&.name
        end

        def distributor_bn_name
          distributor&.bn_name
        end
      end
    end
  end
end
