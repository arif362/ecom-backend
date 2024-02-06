module Finance
  module V1
    module Entities
      class LineItems < Grape::Entity
        expose :id
        expose :variant_id
        expose :product_title
        expose :received_quantity
        expose :qc_passed
        expose :qc_failed, as: :quality_failed
        expose :quantity_failed
        expose :qc_status
        expose :price
        expose :total_price
        expose :quantity
        expose :sku
        expose :code_by_supplier
        expose :send_quantity, as: :sent_quantity

        def product_title
          product&.title || ''
        end

        def sku
          variant&.sku || ''
        end

        def code_by_supplier
          variant&.code_by_supplier || ''
        end

        def variant
          @variant ||= Variant.unscoped.find_by(id: object.variant_id)
        end

        def product
          @product ||= Product.unscoped.find_by(id: variant&.product_id, is_deleted: false)
        end

        def quantity_failed
          object.failed_qcs.quantity_failed.sum(&:quantity)
        end

        def total_price
          object.price.to_d * object.quantity.to_i
        end
      end
    end
  end
end

