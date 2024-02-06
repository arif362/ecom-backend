module Ecommerce
  module V1
    module Entities
      class ShopothLineItems < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :id
        expose :quantity
        expose :price
        expose :unit_price
        expose :sub_total
        expose :discount_amount
        expose :sample_for
        expose :returned_quantity
        expose :refundable
        expose :returnable
        expose :variant_id
        expose :product_id
        expose :product_title
        expose :product_bn_title
        expose :max_quantity_per_order
        expose :product_slug
        expose :product_image
        expose :product_attribute
        expose :reviewed?, as: :is_reviewed
        expose :sample?, as: :is_sample
        expose :is_available
        expose :limit_exceeded?, as: :is_limit_exceeded

        def reviewed?
          object.reviewed?
        end

        def sub_total
          object.sub_total&.ceil
        end

        def unit_price
          object.effective_unit_price.to_i
        end

        def discount_amount
          object.discount_amount&.floor
        end

        def product_id
          product&.id || ''
        end

        def product_title
          product&.title || ''
        end

        def product_bn_title
          product&.bn_title || ''
        end

        def max_quantity_per_order
          product&.max_quantity_per_order || 0
        end

        def product_image
          # product.hero_image.service_url
          product.present? ? image_path(product&.hero_image) : ''
        end

        def product_attribute
          variant&.product_attribute_values&.map do |pa|
            {
              id: pa&.id,
              value: pa&.value,
              bn_value: pa&.bn_value,
            }
          end || []
        end

        def returnable
          return false if options[:list]

          object.returnable?
        end

        def refundable
          product&.is_refundable?
        end

        def product_slug
          product&.slug || ''
        end

        def variant
          @variant ||= Variant.unscoped.find_by(id: object.variant_id)
        end

        def product
          @product ||= Product.unscoped.find_by(id: variant.product_id, is_deleted: false)
        end

        def returned_quantity
          return 0 if options[:list]
          return 0 if object.return_customer_orders.empty?

          object.return_customer_orders.where.not(return_status: :cancelled).count
        end

        def sample?
          object.sample_for.present?
        end

        def is_available
          return false unless options[:list]
          return false unless options[:warehouse].present?
          return false unless variant.product.present?

          wv = variant.warehouse_variants.find_by(warehouse_id: options[:warehouse].id)
          object.quantity <= (wv&.available_quantity || 0)
        end

        def limit_exceeded?
          if product.max_quantity_per_order.present?
            total_quantity = object.cart&.shopoth_line_items&.where(variant_id: product.variants.ids)&.sum(:quantity) || 0
            total_quantity > product.max_quantity_per_order.to_i || false
          else
            false
          end
        end
      end
    end
  end
end
