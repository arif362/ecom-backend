module ShopothWarehouse
  module V1
    module Entities
      class FailedQcs < Grape::Entity
        expose :failable_id, as: :order_id
        expose :failable_type, as: :order_type
        expose :id, as: :failed_qc_id
        expose :quantity, as: :quantity_failed
        expose :variant_id
        expose :sku
        expose :title
        expose :qc_failed_type, as: :failed_type
        expose :received_quantity
        expose :closed_quantity
        expose :open_quantity, as: :remaining_quantity
        expose :is_settled
        expose :created_by

        def sku
          variant&.sku || ''
        end

        def title
          Product.unscoped.find_by(id: variant&.product_id, is_deleted: false)&.title || ''
        end

        def open_quantity
          object.open_quantity || 0
        end

        def variant
          @variant ||= object.variant
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
