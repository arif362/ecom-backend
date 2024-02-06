module Ecommerce
  module V1
    module Entities
      class LineItemForReviews < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper
        expose :customer_order_id, as: :order_id
        expose :title
        expose :bn_title
        expose :quantity
        expose :sub_total, as: :amount
        expose :status
        expose :image

        def title
          product&.title
        end

        def bn_title
          product&.bn_title
        end

        def status
          object.customer_order.status.order_type
        end

        def image
          image_path(product&.hero_image)
        rescue ActiveStorage::FileNotFoundError
          nil
        rescue StandardError => _error
          nil
        end

        def product
          @product ||= Product.unscoped.find_by(id: object.variant&.product_id, is_deleted: false)
        end
      end
    end
  end
end
