module ShopothWarehouse
  module V1
    module Entities
      class ReturnRequests < Grape::Entity
        expose :id, as: :return_id
        expose :customer_order_id
        expose :return_type
        expose :return_status
        expose :product_detatils

        def customer_order_id
          object.customer_order_id
        end

        def product_detatils
          product_detatils = {}
          if object.return_type == 'unpacked'
            # variant = object&.shopoth_line_item&.variant
            product_attribute = variant&.product_attribute_values&.map do |attr_val|
              {
                id: attr_val.id,
                name: attr_val.product_attribute&.name,
                value: attr_val.value,
              }
            end

            product_detatils = {
              category_id: category_id,
              title: variant&.product&.title,
              price: variant&.price_consumer,
              product_attribute_values: product_attribute,
            }
          end
          product_detatils
        end

        def variant
          @variant ||= object&.shopoth_line_item&.variant
        end

        def category_id
          variant.product&.category_ids&.first
        end
      end
    end
  end
end
