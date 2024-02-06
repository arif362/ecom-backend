module Ecommerce
  module V1
    module Entities
      class AreasSearch < Grape::Entity
        expose :id
        expose :thana_id
        expose :name
        expose :bn_name
        expose :home_delivery
        expose :district_id

        def district_id
          object.thana&.district_id
        end
      end
    end
  end
end
