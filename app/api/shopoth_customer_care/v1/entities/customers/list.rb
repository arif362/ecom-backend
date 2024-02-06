module ShopothCustomerCare
  module V1
    module Entities
      module Customers
        class List < Grape::Entity
          expose :id
          expose :full_name, as: :name
          expose :email
          expose :phone
          expose :status
          expose :addresses

          def addresses
            object.addresses.map do |address|
              {
                address_line: address&.address_line,
                area_name: address&.area&.name,
                thana_name: address&.thana&.name,
                district_name: address&.district&.name,
                post_code: address&.zip_code,
              }
            end
          end
        end
      end
    end
  end
end
