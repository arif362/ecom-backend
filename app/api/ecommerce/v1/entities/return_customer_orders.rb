module Ecommerce
  module V1
    module Entities
      class ReturnCustomerOrders < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id, as: :return_id
        expose :backend_id
        expose :customer_order_id
        expose :shopoth_line_item_id
        expose :description
        expose :return_status
        expose :bn_return_status
        expose :created_at
        expose :reason
        expose :return_images
        expose :shopoth_line_item, as: :items

        def shopoth_line_item
          {
            title: product&.title || '',
            bn_title: product&.bn_title || '',
            slug: product&.slug || '',
            quantity: 1,
            variant_id: line_item&.variant_id,
            amount: effective_mrp,
            product_attribute: product_attribute,
            hero_image: hero_image,
          }
        end

        def product_attribute
          line_item&.variant&.product_attribute_values&.map do |pa|
            {
              id: pa&.id,
              value: pa&.value,
              bn_value: pa&.bn_value,
            }
          end || []
        end

        def hero_image
          image_path(product&.hero_image)
        rescue => error
          ''
        end

        def return_images
          if object&.images&.count&.positive?
            image_paths(object.images)
          else
            []
          end
        rescue => error
          []
        end

        def line_item
          @line_item ||= object.shopoth_line_item
        end

        def product
          @product ||= Product.unscoped.find_by(id: line_item&.variant&.product_id)
        end

        def return_status
          object.customer_return_status(object.return_status)
        end

        def bn_return_status
          object.bn_customer_return_status(object.return_status)
        end

        def effective_mrp
          object.cancelled? ? 0 : line_item.effective_unit_price
        end
      end
    end
  end
end
