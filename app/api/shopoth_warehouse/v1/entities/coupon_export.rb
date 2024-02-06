module ShopothWarehouse
  module V1
    module Entities
      class CouponExport < Grape::Entity
        expose :code
        expose :usable_id
        expose :usable_type
        expose :applicable_for
        expose :applicable_on
        expose :is_used

        def applicable_on
          rule_type = rules.find_by(ruleable_type: %w(Variant Category Brand))&.ruleable_type
          rule_ids = rules.where(ruleable_type: rule_type)&.pluck(:ruleable_id)
          fetch_ruleable_names(rule_type, rule_ids) || []
        end

        def applicable_for
          fetch_ruleable_names(object.usable_type, object.usable_id)&.first || ''
        end

        def fetch_ruleable_names(type, ruleable_ids)
          case type
          when 'Variant'
            Variant.where(id: ruleable_ids).pluck(:sku).compact
          when 'Category'
            Category.where(id: ruleable_ids).pluck(:title).compact
          when 'Brand'
            Brand.where(id: ruleable_ids).pluck(:name).compact
          when 'Warehouse'
            Warehouse.where(id: ruleable_ids).pluck(:name).compact
          when 'User'
            User.where(id: ruleable_ids).pluck(:phone).compact
          when 'Partner'
            Partner.where(id: ruleable_ids).pluck(:phone).compact
          when 'District'
            District.where(id: ruleable_ids).pluck(:name).compact
          when 'Thana'
            Thana.where(id: ruleable_ids).pluck(:name).compact
          when 'Area'
            Area.where(id: ruleable_ids).pluck(:name).compact
          end
        end

        def rules
          @rules ||= object.promo_coupon.promo_coupon_rules
        end
      end
    end
  end
end
