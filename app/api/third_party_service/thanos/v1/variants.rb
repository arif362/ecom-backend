module ThirdPartyService
  module Thanos
    module V1
      class Variants < Thanos::Base
        resource :variants do
          desc 'Adding new variant'
          params do
            requires :variant, type: Hash do
              requires :sku, type: String
              requires :product_unique_id, type: String
              requires :variant_unique_id, type: String
              requires :price_consumer, type: Integer
              optional :consumer_discount, type: Float
              optional :product_attribute_value_unique_ids, type: Array
              optional :b2b_discount_type, type: String
              optional :b2b_price, type: Float
              optional :b2b_discount, type: Float
            end
          end
          post do
            product = Product.unscoped.find_by(unique_id: params[:variant][:product_unique_id])
            variant = Variant.unscoped.find_by(unique_id: params[:variant][:variant_unique_id])

            if variant.present?
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json('Variant already exist',
                                                                        HTTP_CODE[:NOT_ACCEPTABLE]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json('Variant already exist',
                                                HTTP_CODE[:NOT_ACCEPTABLE]),
                     HTTP_CODE[:OK])
            end

            unless product.present?
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json('Product not found',
                                                                        HTTP_CODE[:NOT_ACCEPTABLE]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json('Product not found',
                                                HTTP_CODE[:NOT_ACCEPTABLE]),
                     HTTP_CODE[:OK])
            end

            unless product.variable_product?
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json('Variant can be added for variable product',
                                                                        HTTP_CODE[:NOT_ACCEPTABLE]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json('Variant can be added for variable product',
                                                HTTP_CODE[:NOT_ACCEPTABLE]),
                     HTTP_CODE[:OK])
            end

            product_attribute_values = ProductAttributeValue.where(unique_id: params[:variant][:product_attribute_value_unique_ids])
            unless product_attribute_values.present?
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             success_response_with_json('Product Attribute Value Not Found',
                                                                        HTTP_CODE[:NOT_FOUND]),
                                             @current_staff,
                                             true)
              error!(failure_response_with_json('Product attribute value not found',
                                                HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end

            variant = product.variants.create!(
              sku: params[:variant][:sku],
              price_consumer: params[:variant][:price_consumer],
              consumer_discount: params[:variant][:consumer_discount],
              unique_id: params[:variant][:variant_unique_id],
              created_by_id: @current_staff.id,
              product_attribute_values: product_attribute_values,
              b2b_discount_type: params[:variant][:b2b_discount_type],
              b2b_price: params[:variant][:b2b_price],
              b2b_discount: params[:variant][:b2b_discount],
            )
            ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                           success_response_with_json('Variant added successfully',
                                                                      HTTP_CODE[:CREATED]),
                                           @current_staff,
                                           true)
            success_response_with_json('Variant added successfully.',
                                       HTTP_CODE[:CREATED],
                                       ThirdPartyService::Thanos::V1::Entities::Variant.represent(variant))
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to add variant due to: #{error.full_message}"
            ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                           failure_response_with_json("Unable to add variant due to, #{error.message}.",
                                                                      HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                                           @current_staff,
                                           false)
            error!(failure_response_with_json("Unable to add variant due to, #{error.message}.",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end

          desc 'Updating a variant'
          params do
            requires :variant, type: Hash do
              requires :price_consumer, type: Integer
              optional :consumer_discount, type: Float
              optional :product_attribute_value_unique_ids, type: Array
              optional :b2b_discount_type, type: String
              optional :b2b_price, type: Float
              optional :b2b_discount, type: Float
            end
          end
          route_param :unique_id do
            put do
              variant = Variant.find_by(unique_id: params[:unique_id])
              unless variant.present?
                ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                               failure_response_with_json('Variant not found',
                                                                          HTTP_CODE[:NOT_ACCEPTABLE]),
                                               @current_staff,
                                               false)
                error!(failure_response_with_json('Variant not found',
                                                  HTTP_CODE[:NOT_ACCEPTABLE]),
                       HTTP_CODE[:OK])
              end

              product_attribute_values = []
              if variant.product.variable_product?
                product_attribute_values = ProductAttributeValue.where(unique_id: params[:variant][:product_attribute_value_unique_ids])
                unless product_attribute_values.present?
                  ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                                 success_response_with_json('Product Attribute Value Not Found',
                                                                            HTTP_CODE[:NOT_FOUND]),
                                                 @current_staff,
                                                 true)
                  error!(failure_response_with_json('Product attribute value not found',
                                                    HTTP_CODE[:NOT_FOUND]),
                         HTTP_CODE[:OK])
                end
              end


              variant.price_consumer = params[:variant][:price_consumer]
              variant.consumer_discount = params[:variant][:consumer_discount] if params[:variant][:consumer_discount].present?
              variant.product_attribute_values = product_attribute_values if variant.product_attribute_values.present?
              variant.b2b_discount_type = params[:variant][:b2b_discount_type] if params[:variant][:b2b_discount_type].present?
              variant.b2b_price = params[:variant][:b2b_price] if params[:variant][:b2b_price].present?
              variant.b2b_discount = params[:variant][:b2b_discount] if params[:variant][:b2b_discount].present?
              variant.save!

              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             success_response_with_json('Variant updated successfully',
                                                                        HTTP_CODE[:CREATED]),
                                             @current_staff,
                                             true)
              success_response_with_json('Variant updated successfully.',
                                         HTTP_CODE[:CREATED],
                                         ThirdPartyService::Thanos::V1::Entities::Variant.represent(variant))
            rescue StandardError => error
              Rails.logger.error "\n#{__FILE__}\nUnable to update variant due to: #{error.full_message}"
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json("Unable to add variant due to, #{error.message}.",
                                                                        HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json("Unable to update variant due to, #{error.message}.",
                                                HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:OK])
            end
          end

          desc 'Delete a specific variant by thanos'
          route_param :unique_id do
            delete do
              variant = Variant.unscoped.find_by(unique_id: params[:unique_id])
              unless variant.present?
                ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                               failure_response_with_json('Variant not found', HTTP_CODE[:NOT_FOUND]),
                                               @current_staff,
                                               false)
                error!(failure_response_with_json('Variant not found', HTTP_CODE[:NOT_FOUND]),
                       HTTP_CODE[:NOT_FOUND])
              end

              ActiveRecord::Base.transaction do
                var_attrs = ProductAttributeValuesVariant.where(variant_id: variant.id)
                var_attrs.update_all(is_deleted: true) if var_attrs.present?
                suppliers_variants = SuppliersVariant.where(variant_id: variant.id)
                suppliers_variants.update_all(is_deleted: true) if suppliers_variants.present?
                requested_variants = RequestedVariant.where(variant_id: variant.id)
                requested_variants.update_all(is_deleted: true) if requested_variants.present?
                variant.update(is_deleted: true)
              end
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             success_response_with_json('Successfully deleted', HTTP_CODE[:OK]),
                                             @current_staff,
                                             false)

              success_response_with_json('Successfully deleted', HTTP_CODE[:OK])
            rescue StandardError => error
              Rails.logger.info "Variant deletion failed #{error.full_message}"
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json("Variant deletion failed #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json("Variant deletion failed #{error.full_message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end

        end
      end
    end
  end
end
