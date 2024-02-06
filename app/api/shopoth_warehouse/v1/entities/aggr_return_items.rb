# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class AggrReturnItems < Grape::Entity
        expose :id, as: :return_order_id
        expose :return_status
        expose :reason
        expose :return_type
        expose :form_of_return
        expose :created_at, as: :requested_on
        expose :quantity
        expose :amount
        expose :item


        def quantity
          object.quantity
        end

        def amount
          object.shopoth_line_item.sub_total / object.shopoth_line_item.quantity
        end

        def item
          {
            product_title: product&.title || '',
            sku: variant&.sku || '',
            product_attribute_values: product_attribute_values,
          }
        end

        def product_attribute_values
          variant&.product_attribute_values&.map do |pa|
            {
              id: pa&.id || '',
              value: pa&.value || '',
              name: pa&.product_attribute&.name || '',
            }
          end
        end

        def variant
          @variant ||= Variant.unscoped.find_by(id: object.shopoth_line_item.variant_id)
        end

        def product
          @product ||= Product.unscoped.find_by(id: variant.product_id, is_deleted: false)
        end

        def return_type
          object.return_type.titleize
        end

        def form_of_return
          object.form_of_return.titleize
        end

        def return_status
          object.return_status.titleize
        end
      end
    end
  end
end
