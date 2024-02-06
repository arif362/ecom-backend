module ShopothWarehouse
  module V1
    module Entities
      class ProductAttributeValues < Grape::Entity
        expose :id
        expose :product_attribute_id
        expose :value
        expose :bn_value
        expose :product_attribute do |product_attribute_value, _options|
          ShopothWarehouse::V1::Entities::ProductAttributes.represent(product_attribute_value.product_attribute)
        end
      end
    end
  end
end
