# frozen_string_literal: true
module Ecommerce
  module V1
    class Slugs < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::HomepageSerializer
      helpers do
        def fetch_products(product_type_slug)
          if product_type_slug == 'best-selling'
            Product.
              publicly_visible.
              b2c_products.
              joins(:brand, :product_types, main_image_attachment: :blob, variants: :warehouse_variants).
              order(sell_count: :desc)
          else
            product_type = ProductType.find_by(slug: product_type_slug)
            return true unless product_type.present?

            product_type.products.
              publicly_visible.
              b2c_products.
              joins(:brand, main_image_attachment: :blob, variants: :warehouse_variants)
          end
        end
      end
      resource 'slugs' do
        desc 'Fetch product list.'
        route_setting :authentication, optional: true
        params do
          use :pagination, per_page: 50
          requires :slug, type: String
          optional :brands, type: Array
          optional :min_price, type: Float
          optional :max_price, type: Float
          optional :sort_by, type: String
          optional :warehouse_id, type: Integer
          optional :product_attribute_values, type: Array[String]
        end
        get '/products' do
          warehouse = nil
          if params[:warehouse_id].present?
            warehouse = Warehouse.find_by(id: params[:warehouse_id])
            unless warehouse
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.warehouse_not_found'),
                                                HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
          end

          friendly_id_slug = FriendlyIdSlug.find_by(slug: params[:slug])
          unless friendly_id_slug&.sluggable
            error!(failure_response_with_json('Slug not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          products = case friendly_id_slug.sluggable_type
                     when 'Category'
                       category = Category.visible_categories.find_by(slug: params[:slug])
                       unless category
                         error!(failure_response_with_json(I18n.t('Ecom.errors.messages.category_not_found'),
                                                           HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
                       end
                       category.products&.publicly_visible&.b2c_products.includes(:brand, :variants, :product_types, main_image_attachment: :blob)
                     when 'ProductType'
                       product_type = ProductType.find_by(slug: params[:slug])
                       unless product_type || params[:slug] == 'best-selling'
                         error!(failure_response_with_json('Please provide valid product type.',
                                                           HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                       end
                       fetch_products(params[:slug])
                     end

          if params[:product_attribute_values].present?
            products = products.joins(:product_attribute_values).where(product_attribute_values: { value: params[:product_attribute_values] })
          end
          products = Product.products_sort(products, params[:sort_by], params[:brands],
                                           params[:min_price], params[:max_price])
          products = if params[:sort_by].present? || params[:slug] == 'best-selling'
                       products.uniq
                     else
                       Product.order_by_weight_and_available_quantity(products, warehouse&.id).uniq
                     end
          # TODO: Need to Optimize Query
          response = get_homepage_product_list(paginate(Kaminari.paginate_array(products.uniq)), @current_user, warehouse)
          success_response_with_json(I18n.t('Ecom.success.messages.category_product_fetch_successful'),
                                     HTTP_CODE[:OK], { products: response })
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch product list due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.category_products_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get sluggable'
        route_setting :authentication, optional: true
        params do
          optional :warehouse_id, type: Integer
        end
        get '/:slug' do
          friendly_id_slug = FriendlyIdSlug.find_by(slug: params[:slug])
          unless friendly_id_slug
            error!(failure_response_with_json('Slug not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          data = friendly_id_slug.sluggable
          unless data
            error!(failure_response_with_json('Slug related data can not fetch', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          if friendly_id_slug.slug != data.slug
            data = {
              current_slug: data.slug,
            }
            error!(success_response_with_json('Provided slug is old', HTTP_CODE[:MOVED_PERMANENTLY], data), HTTP_CODE[:MOVED_PERMANENTLY])
          end

          # response_data = Ecommerce::V1::Entities::SluggableInfo.represent(data, friendly_id_slug: friendly_id_slug)
          response_data = {
            slug: data.slug,
            page: friendly_id_slug.sluggable_type,
            meta_info: data&.meta_datum&.as_json(except: %i(id)) || {},
          }
          details = {}
          case friendly_id_slug.sluggable_type
          when 'Brand'
            details = Ecommerce::V1::Entities::Brands.represent(data, current_user: @current_user, request_source: @request_source)
          when 'Product'
            warehouse = Warehouse.find_by(id: params[:warehouse_id])
            product = if warehouse.present?
                        product = warehouse.products&.publicly_visible&.find_by(slug: params[:slug])
                        product.nil? ? Product.get_product(params[:slug]) : product
                      else
                        Product.get_product(params[:slug])
                      end

            unless product
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.product_not_found'),
                                                HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
            product&.record_visited(env['REMOTE_ADDR'], @current_user)

            details = Ecommerce::V1::Entities::ProductView.represent(
              product, current_user: @current_user, warehouse: warehouse
            )
          when 'Category'
            category_context = CategoryViews::EcomCategoryFetch.call(category: data, request_source: @request_source)
            details = {
              category: category_context.category_details,
              brands: category_context.brands,
              price_range: category_context.price_range,
              filter_attributes: category_context.attributes,
            }
          when 'HelpTopic'
            articles = data.articles.published.order(id: :desc)
            details = Ecommerce::V1::Entities::Articles.represent(articles)
          when 'Article'
            details = Ecommerce::V1::Entities::Articles.represent(data)
          when 'Partner'
            partner = Partner.includes(:address, :reviews).find_by(slug: params[:slug])
            unless partner
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.store_not_found'),
                                                HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end
            details = Ecommerce::V1::Entities::PartnerDetails.represent(partner, user: @current_user)
          when 'ProductType'
            product_type = ProductType.find_by(slug: params[:slug])
            unless product_type || params[:slug] == 'best-selling'
              error!(failure_response_with_json('Please provide valid product type.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            products = fetch_products(params[:slug])
            minimum_product_price = products&.joins(:variants)&.minimum('variants.effective_mrp') || 0
            maximum_product_price = products&.joins(:variants)&.maximum('variants.effective_mrp') || 100
            price_range = { min_price: minimum_product_price, max_price: maximum_product_price }

            brands = Brand.where(id: products.pluck(:brand_id).compact.uniq)
            brands = Ecommerce::V1::Entities::BrandShortInfos.represent(brands)

            attributes = AttributeSetProductAttribute.get_attributes_and_values(products)

            details = {
              title: product_type&.title,
              bn_title: product_type&.bn_title,
              price_range: price_range || {},
              brands: brands || [],
              attributes: attributes || [],
            }
          end

          response_data[:details] = details

          success_response_with_json('successfully fetch',
                                     HTTP_CODE[:OK], response_data)
        rescue StandardError => error
          error!(failure_response_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
