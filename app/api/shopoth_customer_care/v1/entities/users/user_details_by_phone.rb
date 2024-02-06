module ShopothCustomerCare
  module V1
    module Entities
      module Users
        class UserDetailsByPhone < Grape::Entity
          expose :id
          expose :name
          expose :email
          expose :phone
          expose :addresses
          expose :customer_orders

          def addresses
            object.addresses&.map do |address|
              {
                address_line: address&.address_line,
                area_name: address&.area&.name,
                thana_name: address&.thana&.name,
                district_name: address&.district&.name,
                post_code: address&.zip_code,
              }
            end&.compact&.uniq
          end

          def customer_orders
            ShopothCustomerCare::V1::Entities::OrderDetails.represent(object.customer_orders)
          end
        end
      end
    end
  end
end
