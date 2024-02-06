module ShopothWarehouse
  module V1
    module Entities
      class PromoCoupons < Grape::Entity
        expose :id
        expose :title
        expose :status
        expose :status_key
        expose :start_date
        expose :end_date
        expose :minimum_cart_value
        expose :discount
        expose :max_discount_amount
        expose :order_type
        expose :order_type_key
        expose :discount_type
        expose :discount_type_key
        expose :promo_coupon_rules
        expose :created_by

        def status_key
          PromoCoupon.statuses[object.status]
        end

        def order_type_key
          PromoCoupon.order_types[object.order_type]
        end

        def discount_type_key
          PromoCoupon.discount_types[object.discount_type]
        end

        def promo_coupon_rules
          types = rules.group(:ruleable_type).pluck(:ruleable_type)
          result = []
          2.times do |i|
            rule_ids = rules.where(ruleable_type: types[i]).pluck(:ruleable_id)
            result << fetch_ruleable_name(types[i], rule_ids)
          end
          result
        end

        def fetch_ruleable_name(type, ruleable_ids)
          case type
          when 'Variant'
            { ruleable_type: 'Variant', 'ruleable_values': Variant.where(id: ruleable_ids).pluck(:sku).compact }
          when 'Category'
            { ruleable_type: 'Category', 'ruleable_values': Category.where(id: ruleable_ids).pluck(:title).compact }
          when 'Brand'
            { ruleable_type: 'Brand', 'ruleable_values': Brand.where(id: ruleable_ids).pluck(:name).compact }
          when 'Warehouse'
            { ruleable_type: 'Warehouse', 'ruleable_values': Warehouse.where(id: ruleable_ids).pluck(:name).compact }
          when 'User'
            { ruleable_type: 'User', 'ruleable_values': User.where(id: ruleable_ids).pluck(:phone).compact }
          when 'Partner'
            { ruleable_type: 'Partner', 'ruleable_values': Partner.where(id: ruleable_ids).pluck(:phone).compact }
          when 'District'
            { ruleable_type: 'District', 'ruleable_values': District.where(id: ruleable_ids).pluck(:name).compact }
          when 'Thana'
            { ruleable_type: 'Thana', 'ruleable_values': Thana.where(id: ruleable_ids).pluck(:name).compact }
          when 'Area'
            { ruleable_type: 'Area', 'ruleable_values': Area.where(id: ruleable_ids).pluck(:name).compact }
          else
            { ruleable_type: 'All', 'ruleable_values': [] }
          end
        end

        def rules
          @rules ||= object.promo_coupon_rules
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
