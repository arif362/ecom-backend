module ShopothWarehouse
  module V1
    module Entities
      class RequestedVariants < Grape::Entity
        expose :id
        expose :product_title
        expose :variant_id
        expose :sku
        expose :warehouse
        expose :total_request_count

        def product_title
          product&.title
        end

        def sku
          variant&.sku || ''
        end

        def warehouse
          current_warehouse.name || ''
        end

        def total_request_count
          if current_warehouse.warehouse_type == 'central'
            RequestedVariant.where(variant: variant).count
          else
            RequestedVariant.where(variant: variant, warehouse: current_warehouse).count
          end
        end

        def current_warehouse
          @current_warehouse ||= options[:warehouse]
        end

        def variant
          @variant ||= Variant.unscoped.find_by(id: object.variant_id)
        end

        def product
          @product ||= Product.unscoped.find_by(id: variant.product_id, is_deleted: false)
        end
      end
    end
  end
end
