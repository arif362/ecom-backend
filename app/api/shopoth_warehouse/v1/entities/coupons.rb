module ShopothWarehouse
  module V1
    module Entities
      class Coupons < Grape::Entity
        expose :id
        expose :code, as: :coupon_code
        expose :discount_amount
        expose :start_at
        expose :end_at
        expose :is_used
        expose :usable_id, as: :customer_id
        expose :customer_order_id
        expose :promotion_id
        expose :cart_value
        expose :coupon_type
        expose :is_active
        expose :discount_type
        expose :max_limit
        expose :max_user_limit
        expose :used_count
        expose :skus
        expose :sku_inclusion_type
        expose :phone_numbers
        expose :created_by
        expose :is_visible
        expose :coupon_categories, if: lambda { |object, options| object.coupon_category.present? }

        def discount_amount
          object.discount_amount.to_i || 0
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end

        def coupon_categories
          coupon_category = object&.coupon_category
          {
            id: coupon_category.id,
            category_inclusion_type: coupon_category.category_inclusion_type,
            categories: categories(coupon_category)
          }
        end

        def categories(coupon_category)
          category_ids = coupon_category.category_ids.reject(&:empty?).map(&:to_i)
          categories = []
          category_ids.each do |category_id|
            val = {
              id: category_id,
              title: Category.find_by(id: category_id)&.title
            }
            categories.push(val)
          end
          categories
        end
      end
    end
  end
end
