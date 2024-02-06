module ShopothWarehouse
  module V1
    module Entities
      class UserFindPhones < Grape::Entity
        expose :name
        expose :email
        expose :phone
        expose :address
        def address
          {
            address_line: object.address.address_line,
            area_name: object.address.area.name,
            thana_name: object.address.thana.name,
            district_name: object.address.district.name,
            post_code: object.address&.zip_code,
          }
        end
      end
    end
  end
end
