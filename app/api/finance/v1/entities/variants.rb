module Finance
  module V1
    module Entities
      class Variants < Grape::Entity
        expose :id
        expose :sku
        expose :code_by_supplier
        expose :product_id
        expose :product_title
        expose :price_distribution
        expose :product_attribute_values
        expose :suppliers_variants

        def product_attribute_values
          object.product_attribute_values.map do |attr_val|
            {
              value: attr_val.value
            }
          end
        end

        def suppliers_variants
          variants = object.suppliers_variants.select { |sv| sv.supplier.present? }
          return [] unless variants.present?

          variants.map do |variant|
            {
              id: variant.id,
              variant_id: variant.variant_id,
              supplier_id: variant.supplier_id,
              supplier_name: variant.supplier&.supplier_name,
              supplier_price: variant.supplier_price,
            }
          end
        end

        def product_id
          object&.product&.id
        end

        def product_title
          object&.product&.title
        end
      end
    end
  end
end
