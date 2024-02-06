class Ecommerce::V1::ProductCategory < Ecommerce::Base
  helpers Ecommerce::V1::Serializers::ProductCategorySerializer
  helpers Ecommerce::V1::Helpers::FilterHelper
  helpers Ecommerce::V1::Serializers::HomepageSerializer

  helpers do
    def take_products(category)
      unless category
        error!(failure_response_with_json(I18n.t('Ecom.errors.messages.category_not_found'),
                                          HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
      end
      category.products&.publicly_visible&.b2c_products&.includes(:brand, :variants, :product_types, main_image_attachment: :blob)
    end
  end

  namespace 'product_category' do
    desc "Get a specific category details and it's associated brand list."
    route_setting :authentication, optional: true
    params do
      optional :warehouse_id, type: Integer
    end
    get ':id' do
      category = Category.includes(:sub_categories).visible_categories.find_by(slug: params[:id])
      products = take_products(category)
      minimum_product_price = products.joins(:variants).minimum('variants.effective_mrp') || 0
      maximum_product_price = products.joins(:variants).maximum('variants.effective_mrp') || 100
      price_range = { min_price: minimum_product_price, max_price: maximum_product_price }

      brands = Brand.where(id: products.pluck(:brand_id).compact.uniq)
      brands_info = Ecommerce::V1::Entities::BrandShortInfos.represent(brands)

      category_info = Ecommerce::V1::Entities::Categories.represent(category)
      attributes = AttributeSetProductAttribute.get_attributes_and_values(products)
      response = { category: category_info, brands: brands_info, price_range: price_range,
                   filter_attributes: attributes, }

      success_response_with_json(I18n.t('Ecom.success.messages.advance_filter_fetch_successful'),
                                 HTTP_CODE[:OK], response)
    rescue StandardError => error
      Rails.logger.error "\n#{__FILE__}\nUnable to fetch category details and brand list due to: #{error.message}"
      error!(failure_response_with_json(I18n.t('Ecom.errors.messages.advance_filter_fetch_failed'),
                                        HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
    end

    desc 'Get all products in a category.'
    route_setting :authentication, optional: true
    params do
      use :pagination, per_page: 50
      optional :brand_slug, type: Array
      optional :min_price, type: Float
      optional :max_price, type: Float
      optional :sort_by, type: String
      optional :warehouse_id, type: Integer
      optional :product_attribute_value_ids, type: Array[Integer]
    end

    get ':id/products' do
      warehouse = nil
      if params[:warehouse_id].present?
        warehouse = Warehouse.find_by(id: params[:warehouse_id])
        unless warehouse
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.warehouse_not_found'),
                                            HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
        end
      end

      category = Category.visible_categories.find_by(slug: params[:id])
      products = take_products(category)
      if params[:product_attribute_value_ids].present?
        products = products.joins(:product_attribute_values).where(product_attribute_values: { id: params[:product_attribute_value_ids] })
      end

      products = Product.b2c_products.products_sort(products, params[:sort_by], params[:brand_slug], params[:min_price], params[:max_price])
      products = if params[:sort_by].present?
                   products.uniq
                 else
                   Product.b2c_products.order_by_weight_and_available_quantity(products, warehouse&.id)
                 end
      # TODO: Need to Optimize Query
      response = get_homepage_product_list(paginate(Kaminari.paginate_array(products)), @current_user, warehouse)
      success_response_with_json(I18n.t('Ecom.success.messages.category_product_fetch_successful'),
                                 HTTP_CODE[:OK], response)
    rescue StandardError => error
      Rails.logger.error "\n#{__FILE__}\nUnable to fetch product list due to: #{error.message}"
      error!(failure_response_with_json(I18n.t('Ecom.errors.messages.category_products_fetch_failed'),
                                        HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
    end

    desc 'Get all filter options'
    route_setting :authentication, optional: true
    get '/:id/filter_options' do
      category = Category.find(params[:id])
      get_filter_options(category.products&.publicly_visible)
    end

    desc 'Filter Products based on a category'
    # Option Auth for category based filter route
    # Add params where needed
    params do
      optional :min_price, type: String
      optional :max_price, type: String
      requires :category_ids, type: Array
      optional :product_attribute_ids, type: Array
      optional :product_attribute_value_ids, type: Array
    end
    route_setting :authentication, optional: true
    # TODO: violating http protocol 'post' should be 'get' (Will remove after elastic search is implemented)
    post '/filter' do
      products = Product.publicly_visible.b2c_products.joins(:product_categories).where('product_categories.category_id IN (?)', params[:category_ids])
      # Helper method used, so we can quickly switch/add/remove the filters
      filtered_products = apply_filter(
        params,
        products
      )
      # Serializing as ProductCategorySerialized Defined before
      result = show_by_product_category(paginate(Kaminari.paginate_array(filtered_products)))
      result
    rescue StandardError => ex
      respond_with_json("Unable to fetch due to #{ex.message}",
                        HTTP_CODE[:INTERNAL_SERVER_ERROR])
    end
  end
end
