module Ecommerce
  module V1
    module Entities
      class ProductAttributeValues < Grape::Entity
        expose :id
        expose :value
        expose :bn_value
      end
    end
  end
end
