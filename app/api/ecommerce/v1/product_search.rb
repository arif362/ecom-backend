# frozen_string_literal: true

module Ecommerce
  module V1
    class ProductSearch < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::ProductSerializer
      helpers Ecommerce::V1::Serializers::HomepageSerializer
      helpers do
        def products_fetch(params)
          key = params[:keyword]&.downcase
          if params[:category_slug].present?
            category = Category.find_by(slug: params[:category_slug])
            unless category
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.category_not_found'),
                                                HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
            category.products&.publicly_visible&.b2c_products.where(['LOWER(products.title) LIKE :keyword OR LOWER(products.title) LIKE :middle_keyword OR LOWER(products.bn_title) LIKE :keyword OR LOWER(products.bn_title) LIKE :middle_keyword', keyword: "#{key}%", middle_keyword: "% #{key}%"]).includes(:brand, :variants, main_image_attachment: :blob)
          else
            Product.publicly_visible.b2c_products.where(['LOWER(products.title) LIKE :keyword OR LOWER(products.title) LIKE :middle_keyword OR LOWER(products.bn_title) LIKE :keyword OR LOWER(products.bn_title) LIKE :middle_keyword', keyword: "#{key}%", middle_keyword: "% #{key}%"]).includes(:brand, :variants, main_image_attachment: :blob)
          end
        end

        def product_fetch(product_type_slug)
          if product_type_slug == 'best-selling'
            Product.publicly_visible.b2c_products.includes(:brand, :variants, :product_types, main_image_attachment: :blob)
          else
            Product.publicly_visible.b2c_products.includes(:brand, :variants, :product_types, main_image_attachment: :blob).where(product_types: { slug: product_type_slug })
          end
        end

        def save_search_keyword(keyword, warehouse_id, product_ids)
          Search.find_or_create_by(
            warehouse_id: warehouse_id,
            user: @current_user,
            search_key: keyword,
            product_ids: product_ids,
          )
        end
      end

      namespace 'product' do
        desc 'Product Search.'
        params do
          use :pagination, per_page: 50
          requires :keyword, type: String
          optional :category_slug, type: String
          optional :brand_slug, type: Array
          optional :min_price, type: Integer
          optional :max_price, type: Integer
          optional :sort_by, type: String
          optional :warehouse_id, type: Integer
          optional :product_attribute_value_ids, type: Array[Integer]
        end
        route_setting :authentication, optional: true
        get 'search' do
          warehouse = nil
          products = products_fetch(params)
          if params[:warehouse_id].present?
            warehouse = Warehouse.find_by(id: params[:warehouse_id])
            unless warehouse
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.warehouse_not_found'),
                                                HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
          end

          if params[:product_attribute_value_ids].present?
            products = products.joins(:product_attribute_values).where(
              product_attribute_values: { id: params[:product_attribute_value_ids] },
            )
          end
          products = Product.products_sort(products, params[:sort_by], params[:brand_slug], params[:min_price], params[:max_price])
          unless params[:sort_by].present?
            save_search_keyword(params[:keyword], params[:warehouse_id], products&.ids)
          end

          products = if params[:sort_by].present?
                       products.uniq
                     else
                       Product.order_by_weight_and_available_quantity(products, warehouse&.id)
                     end
          # TODO: Need to Optimize Query
          response = get_grid_product_list(paginate(Kaminari.paginate_array(products.uniq)), @current_user, warehouse)
          success_response_with_json(I18n.t('Ecom.success.messages.product_search_success'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch products due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.product_search_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get all advance filter for a search key.'
        params do
          requires :keyword, type: String
          optional :category_slug, type: String
          optional :warehouse_id, type: Integer
        end
        route_setting :authentication, optional: true
        get 'advance_filter' do
          products = products_fetch(params)
          minimum_product_price = products.joins(:variants).minimum('variants.effective_mrp') || 0
          maximum_product_price = products.joins(:variants).maximum('variants.effective_mrp') || 100
          price_range = { min_price: minimum_product_price, max_price: maximum_product_price }

          brands = Brand.where(id: products.pluck(:brand_id).compact.uniq)
          brands_info = Ecommerce::V1::Entities::BrandShortInfos.represent(brands)
          attributes = AttributeSetProductAttribute.get_attributes_and_values(products)

          response = { brands: brands_info, price_range: price_range, filter_attributes: attributes }
          success_response_with_json(I18n.t('Ecom.success.messages.advance_filter_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch advance filter list due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.advance_filter_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Product Search.'
        params do
          use :pagination, per_page: 50
          requires :keyword, type: String
        end
        route_setting :authentication, optional: true
        get 'elastic-search' do
          products = ProductsIndex.query(query_string: { fields: [:title, :bn_title, :slug], query: params[:keyword], default_operator: 'and' })
          results = []
          JSON.parse(products.to_json).each do |result|
            results << result['attributes']
          end
          # TODO: Need to Optimize Query
          success_response_with_json('Successfully fetched searched products', HTTP_CODE[:OK], paginate(Kaminari.paginate_array(results)))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch elasticsearch products due to: #{error.message}"
          failure_response_with_json('Unable to fetch products.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc "Get advanced filter options for a specific product type's products."
        route_setting :authentication, optional: true
        params do
          requires :product_type, type: String
          optional :warehouse_id, type: Integer
        end
        get '/filter_options' do
          product_type = ProductType.find_by(slug: params[:product_type])
          unless product_type || params[:product_type] == 'best-selling'
            error!(failure_response_with_json('Please provide valid product type.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end

          products = product_fetch(params[:product_type])
          minimum_product_price = products.joins(:variants).minimum('variants.effective_mrp') || 0
          maximum_product_price = products.joins(:variants).maximum('variants.effective_mrp') || 100
          price_range = { min_price: minimum_product_price, max_price: maximum_product_price }

          brands = Brand.where(id: products.compact.pluck(:brand_id))
          brands_info = Ecommerce::V1::Entities::BrandShortInfos.represent(brands)

          attributes = AttributeSetProductAttribute.get_attributes_and_values(products)
          response = { brands: brands_info, price_range: price_range, filter_attributes: attributes }

          success_response_with_json(I18n.t('Ecom.success.messages.advance_filter_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch advance filter due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.advance_filter_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get filtered products of a specific product type.'
        route_setting :authentication, optional: true
        params do
          use :pagination, per_page: 50
          requires :product_type, type: String
          optional :brand_slug, type: Array
          optional :min_price, type: Float
          optional :max_price, type: Float
          optional :sort_by, type: String
          optional :warehouse_id, type: Integer
          optional :product_attribute_value_ids, type: Array[Integer]
        end
        get '/filter' do
          warehouse = nil
          if params[:warehouse_id].present?
            warehouse = Warehouse.find_by(id: params[:warehouse_id])
            unless warehouse
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.warehouse_not_found'),
                                                HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
          end

          product_type = ProductType.find_by(slug: params[:product_type])
          unless product_type || params[:product_type] == 'best-selling'
            error!(failure_response_with_json('Please provide valid product type.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end

          products = product_fetch(params[:product_type])
          if params[:product_attribute_value_ids].present?
            products = products.joins(:product_attribute_values).where(product_attribute_values: { id: params[:product_attribute_value_ids] })
          end

          products = Product.products_sort(products, params[:sort_by], params[:brand_slug], params[:min_price], params[:max_price])
          products = if params[:sort_by].present?
                       products
                     else
                       Product.order_by_weight_and_available_quantity(products, warehouse&.id, params[:product_type])
                     end
          # TODO: Need to Optimize Query
          response = get_homepage_product_list(paginate(Kaminari.paginate_array(products.uniq)), @current_user, warehouse)
          success_response_with_json(I18n.t('Ecom.success.messages.product_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to filter products due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.product_filter_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
