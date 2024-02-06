module Ecommerce
  module V1
    module Entities
      class ThanasSearch < Grape::Entity
        expose :id
        expose :district_id
        expose :name
        expose :bn_name
        expose :home_delivery
      end
    end
  end
end
