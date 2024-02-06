module ShopothWarehouse
  module V1
    module Entities
      class RouteBalances < Grape::Entity
        expose :id, as: :route_id
        expose :title
        expose :bn_title
        expose :phone
        expose :cash_amount
        # expose :digital_amount
        expose :return_requests
        expose :return_orders

        # def digital_amount
        #   object.create_wallet(currency_amount: 0.0, currency_type: 'Tk.') if object.wallet.nil?
        #   object&.wallet&.currency_amount
        # end

        def return_requests
          return_requests = object.return_customer_orders.where(return_status: 'in_transit')
          ShopothWarehouse::V1::Entities::ReturnRequests.represent(return_requests)
        end

        def return_orders
          order_status = %w(in_transit_partner_switch in_transit_cancelled in_transit_reschedule in_transit_delivery_switch)
          customer_orders = object.customer_orders.map do |customer_order|
            customer_order if order_status.include?(customer_order.status.order_type.to_s)
          end.flatten.compact
          ShopothWarehouse::V1::Entities::CustomerOrderList.represent(customer_orders)
        end
      end
    end
  end
end
