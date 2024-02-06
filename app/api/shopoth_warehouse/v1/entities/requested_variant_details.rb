module ShopothWarehouse
  module V1
    module Entities
      class RequestedVariantDetails < Grape::Entity
        expose :id, as: :variant_id
        expose :product_title
        expose :sku
        expose :total_request_count
        expose :user_details

        def product_title
          product.title
        end

        def sku
          object.sku
        end

        def total_request_count
          requested_variants.count
        end

        def user_details
          requested_variants.map do |requested_variant|
            user = requested_variant&.user
            {
              warehouse: requested_variant.warehouse&.name || '',
              customer_name: user&.full_name || '',
              mobile_number: user&.phone || '',
              email: user&.email || '',
            }
          end
        end

        def requested_variants
          @requested_variants ||= if options[:warehouse].warehouse_type == 'central'
                                    object.requested_variants
                                  else
                                    object.requested_variants.where(warehouse: options[:warehouse])
                                  end
        end

        def product
          @product ||= Product.unscoped.find_by(id: object.product_id, is_deleted: false)
        end
      end
    end
  end
end
