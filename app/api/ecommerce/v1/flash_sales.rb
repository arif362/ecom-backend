# frozen_string_literal: true

module Ecommerce
  module V1
    class FlashSales < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::HomepageSerializer

      helpers do
        def warehouse
          @warehouse ||= Warehouse.find_by(id: params[:warehouse_id])
        end
      end

      namespace :flash_sales do
        desc 'Flash sale filter options.'
        params do
          optional :warehouse_id, type: Integer
        end
        route_setting :authentication, optional: true
        get :filter_options do
          flash_sale_products = Product.fetch_flash_sales
          if flash_sale_products.present?
            flash_sale = flash_sale_products[:flash_sale]
            products = flash_sale_products[:products]
            price_range = Product.min_max_price(warehouse, products)
            brands = Brand.where(id: products.pluck(:brand_id).compact.uniq)
            attributes = AttributeSetProductAttribute.get_attributes_and_values(products)
            response = {
              flash_sale: flash_sale(flash_sale, @current_user, [], warehouse),
              brands: Ecommerce::V1::Entities::BrandShortInfos.represent(brands, current_user: @current_user),
              filter_attributes: attributes,
              price_range: price_range,
            }
            success_response_with_json('Successfully fetch flash sale products.', HTTP_CODE[:OK], response)
          else
            success_response_with_json('Successfully fetch flash sale products.', HTTP_CODE[:OK])
          end
        rescue StandardError => error
          Rails.logger.info "\n#{__FILE__}\nFail to fetch filter options in flash sale #{error.message}"
          error!(failure_response_with_json('Fail to fetch due to internal error.', HTTP_CODE[:NO_CONTENT]))
        end

        desc 'Get products for flash sale.'
        params do
          use :pagination, per_page: 50
          optional :warehouse_id, type: Integer
          optional :brand_slug, type: Array
          optional :min_price, type: Float
          optional :max_price, type: Float
          optional :sort_by, type: String
          optional :product_attribute_value_ids, type: Array[Integer]
        end
        route_setting :authentication, optional: true
        get :products do
          flash_sales = Product.fetch_flash_sales
          if flash_sales.present?
            products = flash_sales[:products]
            if params[:product_attribute_value_ids].present?
              products.attributes_wise_products(params[:product_attribute_value_ids])
            end
            products = Product.products_sort(products, params[:sort_by], params[:brand_slug],
                                             params[:min_price], params[:max_price])
            products = if params[:sort_by].present?
                         products.uniq
                       else
                         Product.order_by_weight_and_available_quantity(products, warehouse&.id)
                       end
            # TODO: Need to Optimize Query
            success_response_with_json('Successfully fetch flash sale products.', HTTP_CODE[:OK],
                                       get_homepage_product_list(paginate(Kaminari.paginate_array(products.uniq)),
                                                                 @current_user, warehouse))
          else
            error!(failure_response_with_json('Flash sale products not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end
        rescue StandardError => error
          Rails.logger.info "\n#{__FILE__}\nUnable to fetch flash sale products due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch flash sale products.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
