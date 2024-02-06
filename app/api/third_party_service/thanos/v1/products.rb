# frozen_string_literal: true

module ThirdPartyService
  module Thanos
    module V1
      class Products < Thanos::Base
        helpers do
          def get_parent_category_ids(leaf_category)
            category_ids = []
            category = leaf_category
            until category.nil?
              category_ids.push(category.id)
              category = category.parent
            end
            category_ids
          end
        end
        resource :products do
          desc 'Create Product'
          params do
            requires :product, type: Hash do
              requires :unique_id, type: String
              requires :title, type: String
              requires :bn_title, type: String
              requires :description, type: String
              requires :sku_type, type: Integer
              requires :company, type: String
              requires :product_type, type: String
              requires :brand_unique_id, type: String
              requires :leaf_category_unique_id, type: String
              optional :attribute_set_unique_id, type: String
              optional :business_type, type: String, values: Product.business_types.keys
              requires :variants_attributes, type: Array do
                requires :sku, type: String
                requires :unique_id, type: String
                requires :price_consumer, type: Integer
                optional :consumer_discount, type: Float
                optional :product_attribute_value_unique_ids, type: Array
                optional :b2b_discount_type, type: String
                optional :b2b_price, type: Float
                optional :b2b_discount, type: Float
              end
            end
          end
          post do
            unless params[:product][:unique_id].present?
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json('Unique ID of product is missing',
                                                                        HTTP_CODE[:NOT_ACCEPTABLE]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json('Unique ID of product is missing',
                                                HTTP_CODE[:NOT_ACCEPTABLE]),
                     HTTP_CODE[:NOT_ACCEPTABLE])
            end
            product = Product.unscoped.find_by(unique_id: params[:product][:unique_id])
            if product.present?
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json('Product with same uuid already exists',
                                                                        HTTP_CODE[:NOT_ACCEPTABLE]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json('Product with same uuid already exists',
                                                HTTP_CODE[:NOT_ACCEPTABLE]),
                     HTTP_CODE[:OK])
            end
            leaf_category = Category.find_by(unique_id: params[:product][:leaf_category_unique_id])
            unless leaf_category
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json('Leaf category not found',
                                                                        HTTP_CODE[:NOT_FOUND]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json('Leaf category not found',
                                                HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
            root_category = Category.fetch_parent_category(leaf_category)
            brand = Brand.find_by(unique_id: params[:product][:brand_unique_id])
            unless brand
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json('Brand not found',
                                                                        HTTP_CODE[:NOT_FOUND]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json('Brand not found',
                                                HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
            attribute_set = nil
            if params[:product][:sku_type] == Product.sku_types[:variable_product]
              attribute_set = AttributeSet.find_by(unique_id: params[:product][:attribute_set_unique_id])
              unless attribute_set
                ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                               failure_response_with_json('Attribute set not found',
                                                                          HTTP_CODE[:NOT_FOUND]),
                                               @current_staff,
                                               false)
                error!(failure_response_with_json('Attribute set not found',
                                                  HTTP_CODE[:NOT_FOUND]),
                       HTTP_CODE[:OK])
              end
            end
            product = Product.new(
              title: params[:product][:title],
              bn_title: params[:product][:bn_title],
              short_description: params[:product][:description],
              bn_short_description: params[:product][:description],
              warranty_type: 0,
              sku_type: params[:product][:sku_type],
              company: params[:product][:company],
              bn_company: params[:product][:company],
              product_type: params[:product][:product_type],
              leaf_category: leaf_category,
              root_category_id: root_category,
              slug: params[:product][:unique_id],
              brand: brand,
              attribute_set: attribute_set,
              public_visibility: false,
              created_by_id: @current_staff.id,
              unique_id: params[:product][:unique_id],
              business_type: params[:product][:business_type],
              hero_image_file: {
                tempfile: File.open(Rails.root.join('public', '1kb-image.png')),
                filename: '1kb-image.png',
                type: 'image/jpg',
              },
            )
            category_ids = get_parent_category_ids(leaf_category)
            category_ids.each do |category_id|
              product.product_categories.build(
                category_id: category_id,
                created_by_id: @current_staff.id,
              )
            end
            params[:product][:variants_attributes].each do |variants_attribute|
              product_attribute_values = []
              if product.variable_product?
                unless variants_attribute[:product_attribute_value_unique_ids].present?
                  ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                                 failure_response_with_json('Product Attribute Value Unique IDs are missing',
                                                                            HTTP_CODE[:NOT_ACCEPTABLE]),
                                                 @current_staff,
                                                 false)
                  error!(failure_response_with_json('Product Attribute Value Unique IDs are missing',
                                                    HTTP_CODE[:NOT_ACCEPTABLE]),
                         HTTP_CODE[:NOT_ACCEPTABLE])
                end
                product_attribute_values = ProductAttributeValue.where(unique_id: variants_attribute[:product_attribute_value_unique_ids])
                # TODO: Check product_attribute_values with attributes of attribute_set
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
              product.variants.build(
                sku: variants_attribute[:sku],
                price_consumer: variants_attribute[:price_consumer],
                consumer_discount: variants_attribute[:consumer_discount],
                discount_type: 1,
                unique_id: variants_attribute[:unique_id],
                created_by_id: @current_staff.id,
                product_attribute_values: product_attribute_values,
                b2b_discount_type: variants_attribute[:b2b_discount_type],
                b2b_price: variants_attribute[:b2b_price],
                b2b_discount: variants_attribute[:b2b_discount],
              )
            end
            product.save!
            ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                           success_response_with_json('Product Created Successfully',
                                                                      HTTP_CODE[:CREATED]),
                                           @current_staff,
                                           true)
            success_response_with_json('Product Created Successfully.',
                                       HTTP_CODE[:CREATED],
                                       ThirdPartyService::Thanos::V1::Entities::Product.represent(product))
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to create product due to: #{error.full_message}"
            ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                           failure_response_with_json("Unable to create product due to, #{error.message}.",
                                                                      HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                                           @current_staff,
                                           false)
            error!(failure_response_with_json("Unable to create product due to, #{error.message}.",
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
          desc 'Update Product'
          route_param :unique_id do
            params do
              requires :product, type: Hash do
                requires :title, type: String
                requires :bn_title, type: String
                requires :description, type: String
                requires :company, type: String
                requires :product_type, type: String
                requires :brand_unique_id, type: String
                requires :leaf_category_unique_id, type: String
                optional :business_type, type: String, values: Product.business_types.keys
              end
            end
            put do
              product = Product.unscoped.find_by(unique_id: params[:unique_id])
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
              leaf_category = Category.find_by(unique_id: params[:product][:leaf_category_unique_id])
              unless leaf_category
                ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                               failure_response_with_json('Leaf category not found',
                                                                          HTTP_CODE[:NOT_FOUND]),
                                               @current_staff,
                                               false)
                error!(failure_response_with_json('Leaf category not found',
                                                  HTTP_CODE[:NOT_FOUND]),
                       HTTP_CODE[:OK])
              end
              root_category = Category.fetch_parent_category(leaf_category)
              brand = Brand.find_by(unique_id: params[:product][:brand_unique_id])
              unless brand
                ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                               failure_response_with_json('Brand not found',
                                                                          HTTP_CODE[:NOT_FOUND]),
                                               @current_staff,
                                               false)
                error!(failure_response_with_json('Brand not found',
                                                  HTTP_CODE[:NOT_FOUND]),
                       HTTP_CODE[:OK])
              end
              unless product.leaf_category == leaf_category
                product.product_categories.destroy_all
                category_ids = get_parent_category_ids(leaf_category)
                category_ids.each do |category_id|
                  product.product_categories.build(
                    category_id: category_id,
                    created_by_id: @current_staff.id,
                  )
                end
              end
              product.update!(
                title: params[:product][:title],
                bn_title: params[:product][:bn_title],
                short_description: params[:product][:description],
                bn_short_description: params[:product][:description],
                warranty_type: 0,
                company: params[:product][:company],
                bn_company: params[:product][:company],
                product_type: params[:product][:product_type],
                leaf_category: leaf_category,
                root_category_id: root_category,
                brand: brand,
                business_type: params[:product][:business_type],
              )
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             success_response_with_json('Product updated Successfully',
                                                                        HTTP_CODE[:CREATED]),
                                             @current_staff,
                                             true)
              success_response_with_json('Product updated Successfully.', HTTP_CODE[:OK])
            rescue StandardError => error
              Rails.logger.error "\n#{__FILE__}\nUnable to create product due to: #{error.full_message}"
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json("Unable to update product due to, #{error.message}.",
                                                                        HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json("Unable to update product due to, #{error.message}.",
                                                HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:OK])
            end
          end

          desc 'Delete a specific product by thanos'
          route_param :unique_id do
            delete do
              product = Product.unscoped.find_by(unique_id: params[:unique_id])
              unless product.present?
                ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                               failure_response_with_json('Product not found', HTTP_CODE[:NOT_FOUND]),
                                               @current_staff,
                                               false)
                error!(failure_response_with_json('Product not found', HTTP_CODE[:NOT_FOUND]),
                       HTTP_CODE[:NOT_FOUND])
              end
              if product.shopoth_line_items.present?
                ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                               failure_response_with_json('This product is present in cart or customer orders', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                                               @current_staff,
                                               false)

                error!(failure_response_with_json('This product is present in cart or customer orders',
                                                  HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
              ActiveRecord::Base.transaction do
                if product.product_attribute_images.present?
                  product.product_attribute_images.update_all(is_deleted: true)
                end
                var_attrs = ProductAttributeValuesVariant.where(variant_id: product.variants.ids)
                var_attrs.update_all(is_deleted: true) if var_attrs.present?
                suppliers_variants = SuppliersVariant.where(variant_id: product.variants.ids)
                suppliers_variants.update_all(is_deleted: true) if suppliers_variants.present?
                requested_variants = RequestedVariant.where(variant_id: product.variants.ids)
                requested_variants.update_all(is_deleted: true) if requested_variants.present?
                product.variants.update_all(is_deleted: true) if product.variants.present?
                product.update(is_deleted: true)
              end
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             success_response_with_json('Successfully deleted', HTTP_CODE[:OK]),
                                             @current_staff,
                                             false)

              success_response_with_json('Successfully deleted', HTTP_CODE[:OK])
            rescue StandardError => error
              Rails.logger.info "Product deletion failed #{error.message}"
              ThirdPartyLogJob.perform_later(request.headers.merge(params: params),
                                             failure_response_with_json("Product deletion failed #{error.full_message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                                             @current_staff,
                                             false)
              error!(failure_response_with_json('Unable to delete', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        end
      end
    end
  end
end
