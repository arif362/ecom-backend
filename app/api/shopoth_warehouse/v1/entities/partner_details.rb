module ShopothWarehouse
  module V1
    module Entities
      class PartnerDetails < Grape::Entity
        include ShopothWarehouse::V1::Helpers::ImageHelper

        expose :id
        expose :name
        expose :phone
        expose :status
        expose :schedule
        expose :tsa_id
        expose :region
        expose :area
        expose :territory
        # expose :wallet_balance
        expose :route
        expose :address

        def address
          address = object.address
          if address.present?
            {
              id: address.id,
              area_name: address&.area&.name,
              thana_name: address&.thana&.name,
              district_name: address&.district&.name,
              address_line: object.address.address_line,
            }
          end
        end

        def route
          route = object.route
          if route.present?
            {
              id: route.id,
              title: route.title,
              phone: route.phone,
              sr_point: route.sr_point,
              sr_name: route.sr_name

            }
          end
        end

        def wallet_balance
          object.create_wallet(currency_amount: 0.0, currency_type: 'Tk.') if object.wallet.nil?
          object&.wallet&.currency_amount
        end
      end
    end
  end
end