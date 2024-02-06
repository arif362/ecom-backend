module ShopothWarehouse
  module V1
    module Entities
      class RouteDeviceDetails < Grape::Entity
        expose :id
        expose :title
        expose :phone
        expose :cash_amount
        expose :wallet_amount
        expose :return_requests
        expose :created_by

        def wallet_amount
          object.create_wallet(currency_amount: 0.0, currency_type: 'Tk.') if object.wallet.nil?
          object&.wallet&.currency_amount
        end

        def return_requests
          requests = []
          object.partners.each do |partner|
            returns = partner.return_customer_orders.where(return_status: 'in_transit')
            returns.each do |req|
              requests << req
            end
          end
          ShopothWarehouse::V1::Entities::ReturnRequests.represent(requests)
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
