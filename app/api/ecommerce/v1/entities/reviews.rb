module Ecommerce
  module V1
    module Entities
      class Reviews < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :title
        expose :description
        expose :rating
        expose :user_id
        expose :user_name
        expose :shopoth_line_item_id
        expose :images
        expose :is_recommended
        expose :reviewable
        expose :customer_order_id
        expose :created_at

        def images
          if object&.images&.count&.positive?
            image_paths(object&.images)
          else
            []
          end
        end

        def user_name
          object&.user&.full_name
        end

        def reviewable
          if object.reviewable_type == 'Partner'
            {
              id: object&.reviewable_id,
              type: object&.reviewable_type,
              name: object&.reviewable&.name,
            }
          else
            {
              id: object&.reviewable_id,
              type: object&.reviewable_type,
              name: object&.reviewable&.product&.title,
            }
          end
        end
      end
    end
  end
end
