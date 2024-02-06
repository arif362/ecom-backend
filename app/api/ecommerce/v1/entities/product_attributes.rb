module Ecommerce
  module V1
    module Entities
      class ProductAttributes < Grape::Entity
        expose :id
        expose :name
        expose :bn_name
        expose :product_attribute_values, as: :values, with: Ecommerce::V1::Entities::ProductAttributeValues
      end
    end
  end
end
