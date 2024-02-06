# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class BlockedItems < Grape::Entity
        expose :id
        expose :product_title
        expose :sku
        expose :blocked_quantity
        expose :garbage_quantity
        expose :unblocked_quantity
        expose :blocked_reason
        expose :variant_id

        def product_title
          Product.unscoped.find_by(id: object.variant&.product_id, is_deleted: false)&.title || ''
        end

        def sku
          object&.variant&.sku
        end

        def blocked_reason
          object.blocked_reason.humanize
        end
      end
    end
  end
end
