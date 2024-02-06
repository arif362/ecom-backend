module Ecommerce
  module V1
    module Entities
      class Address < Grape::Entity
        expose :id
        expose :title, as: :address_title
        expose :name
        expose :bn_name
        expose :phone
        expose :district_id
        expose :thana_id
        expose :area_id
        expose :district_name
        expose :district_bn_name
        expose :thana_name
        expose :thana_bn_name
        expose :area_name
        expose :area_bn_name
        expose :address_line
        expose :bn_address_line
        expose :zip_code

        def district_name
          district&.name
        end

        def district_bn_name
          district&.bn_name
        end

        def thana_name
          thana&.name
        end

        def thana_bn_name
          thana&.bn_name
        end

        def area_name
          area&.name
        end

        def area_bn_name
          area&.bn_name
        end

        def district
          @district ||= object&.district
        end

        def thana
          @thana ||= object&.thana
        end

        def area
          @area ||= object&.area
        end
      end
    end
  end
end
