# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class CustomerOrders < ShopothWarehouse::Base
      resource :customer_orders do
        route_param :id do
          desc 'get agent commission details with customer order'
          route_setting :authentication, type: RouteDevice
          get 'agent_commission_details' do
            customer_order = CustomerOrder.find params[:id]

            if customer_order.present?
              present customer_order, with: ShopothWarehouse::V1::Entities::AgentCommission
            else
              status :not_found
              { status_code: :not_found, message: 'Customer order not found' }
            end
          rescue => ex
            error! respond_with_json("Unable to fetch customer order due to #{ex.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end

          desc 'get Partner margin details with customer order'
          route_setting :authentication, type: RouteDevice
          get 'partner_margin_details' do
            customer_order = CustomerOrder.find params[:id]

            if customer_order.present?
              present customer_order, with: ShopothWarehouse::V1::Entities::PartnerMargin
            else
              status :not_found
              { status_code: :not_found, message: 'Customer order not found' }
            end
          rescue => ex
            error! respond_with_json("Unable to fetch customer order due to #{ex.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end
        end
      end
    end
  end
end
