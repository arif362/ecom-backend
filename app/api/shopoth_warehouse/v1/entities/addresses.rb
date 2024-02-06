module ShopothWarehouse
  module V1
    module Entities
      class Addresses < Grape::Entity
        expose :id
        expose :area_id
        expose :area_name
        expose :thana_id
        expose :thana_name
        expose :district_id
        expose :district_name
        expose :name
        expose :address_line
        expose :bn_address_line
        expose :phone
        expose :zip_code, as: :post_code

        def area_name
          object&.area&.name
        end

        def thana_name
          object&.thana&.name
        end

        def district_name
          object&.district&.name
        end
      end
    end
  end
end
