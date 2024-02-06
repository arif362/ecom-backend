module ShopothWarehouse
  module V1
    module Entities
      class Promotions < Grape::Entity
        expose :id
        expose :title
        expose :from_date
        expose :to_date
        expose :is_active
        expose :is_time_bound
        expose :start_time
        expose :end_time
        expose :days
        expose :promotion_category
        expose :rule
        expose :promotion_variants
        expose :promotion_rules
        expose :promotion_brands
        expose :created_by

        def promotion_variants
          return [] if options[:list]

          promotion_variants = object.promotion_variants.group_by(&:state)
          sku_variants(promotion_variants)
        end

        def sku_variants(promotion_variants)
          promotion_variants.map do |state, v|
            {
              name: key_name(state),
              values: v.map do |v|
                {
                  variant_id: v.variant_id,
                  sku: v.variant.sku,
                }
              end,
            }
          end
        end

        def promotion_rules
          return [] if options[:list]

          promotion_rules = object.promotion_rules
          ShopothWarehouse::V1::Entities::PromotionRules.represent(promotion_rules)
        end

        def promotion_brands
          return [] if options[:list]

          promo_brands = object.brand_promotions.group_by(&:state)
          promo_brands(promo_brands)
        end

        def promo_brands(promos)
          promos.map do |state, v|
            {
              name: state,
              values: v.map do |v|
                {
                  brand_id: v.brand_id,
                  brand_name: v.brand&.name,
                }
              end,
            }
          end
        end

        def key_name(state)
          case state
          when 'buy'
            'x_skus'
          when 'get'
            'y_skus'
          when 'sku_promo'
            'variant_skus'
          else
            ''
          end
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
