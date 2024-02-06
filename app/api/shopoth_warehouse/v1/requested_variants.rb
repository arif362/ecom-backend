# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class RequestedVariants < Ecommerce::Base
      resources :requested_variants do
        desc 'Get all requested variant.'
        get do
          requested_variants =
            if check_wh_warehouse
              RequestedVariant.all.uniq { |rv| [rv.variant_id, rv.warehouse_id] }
            else
              @current_staff.warehouse.requested_variants.uniq { |rv| [rv.variant_id, rv.warehouse_id] }
            end

          response = ShopothWarehouse::V1::Entities::RequestedVariants.represent(
            requested_variants, warehouse: @current_staff.warehouse
          )
          success_response_with_json('Successfully fetched requested products.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch requested products due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch requested products.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY], []), HTTP_CODE[:OK])
        end

        desc 'Get details of a specific requested variant.'
        params do
          requires :variant_id, type: Integer
        end
        get '/details' do
          variant = Variant.find_by(id: params[:variant_id])
          unless variant
            error!(failure_response_with_json('Variant not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          response = ShopothWarehouse::V1::Entities::RequestedVariantDetails.represent(
            variant, warehouse: @current_staff.warehouse
          )
          success_response_with_json('Successfully fetched details of requested product.', HTTP_CODE[:OK],
                                     response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch details of requested product due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch details of requested product.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
