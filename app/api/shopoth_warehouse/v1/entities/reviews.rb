module ShopothWarehouse
  module V1
    module Entities
      class Reviews < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :title
        expose :description
        expose :rating
        expose :user_id
        expose :is_approved
        expose :shopoth_line_item_id
        expose :images
        expose :reviewable_id
        expose :reviewable_type
        expose :reviewable_name


        def images
          image_paths(object&.images)
        rescue ActiveStorage::FileNotFoundError
          nil
        end

        def reviewable_name
          object.reviewable_type == 'Partner' ? object.reviewable&.name : Product.unscoped.find_by(id: object.reviewable&.product_id, is_deleted: false)&.title
        end
      end
    end
  end
end
