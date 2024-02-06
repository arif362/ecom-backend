# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class BlockedItemsExport < Grape::Entity
        expose :id
        expose :product_title
        expose :sku
        expose :blocked_quantity
        expose :garbage_quantity
        expose :unblocked_quantity
        expose :blocked_reason
        expose :variant_id
        expose :product_code
        expose :category
        expose :sub_category
        expose :quantity
        expose :mrp

        def product_title
          product&.title || ''
        end

        def sku
          object&.variant&.sku
        end

        def blocked_reason
          object.blocked_reason&.humanize
        end

        def product_code
          product&.id
        end

        def category
          product&.root_category&.title || ''
        end

        def sub_category
          product&.leaf_category&.title || ''
        end

        def quantity
          object.blocked_quantity
        end

        def mrp
          object.variant&.effective_mrp
        end

        def product
          @product ||= Product.unscoped.find_by(id: object.variant&.product_id, is_deleted: false)
        end
      end
    end
  end
end
