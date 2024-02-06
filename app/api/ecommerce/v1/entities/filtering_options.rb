module Ecommerce
  module V1
    module Entities
      class FilteringOptions < Grape::Entity

        expose :id
        expose :filtering_type
        expose :filtering_keys

        def filtering_keys
          keys = []
          case object&.filtering_type
          when 'category'
            object&.filtering_keys.each do |key|
              category = Category.find_by(id: key)
              keys << { id: category&.id, key_name: category&.title }
            end
          when 'product_attribute'
            object&.filtering_keys.each do |key|
              attribute = ProductAttribute.find_by(id: key)
              keys << { id: attribute&.id, key_name: attribute&.name }
            end
          when 'product_type'
            object&.filtering_keys.each do |key|
              product_type = ProductType.find_by(id: key)
              keys << { id: product_type&.id, key_name: product_type&.title }
            end
          else
            keys = object&.filtering_keys
          end
          keys
        end
      end
    end
  end
end
