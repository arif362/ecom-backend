# frozen_string_literal: true

module Ecommerce
  module V1
    class RequestedVariants < Ecommerce::Base
      resources :requested_variants do
        desc 'Request for variant.'
        params do
          requires :warehouse_id, type: Integer
          requires :variant_id, type: Integer
        end
        post do
          warehouse = Warehouse.find_by(id: params[:warehouse_id])
          unless warehouse
            return { success: false, status: HTTP_CODE[:NOT_FOUND], message: 'Warehouse not Found.', data: {} }
          end

          variant = Variant.find_by(id: params[:variant_id])
          unless variant
            return { success: false, status: HTTP_CODE[:NOT_FOUND], message: 'Variant not Found.', data: {} }
          end

          existing_request = @current_user.requested_variants.find_by(variant_id: variant.id, warehouse_id: warehouse.id)
          if existing_request
            return { success: false, status: HTTP_CODE[:FORBIDDEN], message: 'You have already requested this product.', data: {} }
          end

          @current_user.requested_variants.create!(warehouse: warehouse, variant: variant)
          return { success: true, status: HTTP_CODE[:OK], message: 'Successfully requested for this product.', data: {} }
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to request for product due to: #{error.message}"
          return { success: false, status: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: 'Unable to request for product.', data: {} }
        end
      end
    end
  end
end
