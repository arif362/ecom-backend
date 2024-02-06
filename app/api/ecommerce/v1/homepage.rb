# frozen_string_literal: true

class Ecommerce::V1::Homepage < Ecommerce::Base
  helpers Ecommerce::V1::Serializers::ProductSerializer
  helpers Ecommerce::V1::Serializers::ProductCategorySerializer
  helpers Ecommerce::V1::Serializers::HomepageSerializer
  helpers do
    def homepage_products_fetch(category, keyword, warehouse_id)
      products = if category.present?
                   category.products&.publicly_visible&.where(['LOWER(products.title) LIKE ?', "#{keyword.downcase}%"])
                 else
                   Product.publicly_visible.where(['LOWER(products.title) LIKE ?', "#{keyword.downcase}%"])
                 end
      products = products.b2c_products
      Product.order_by_weight_and_available_quantity(products, warehouse_id).first(10)
    end

    def homepage_user_friendly_search(category, keyword, warehouse = nil)
      keyword = keyword.downcase
      brands = Brand
                 .select(:id, :name, :bn_name, :slug)
                 .where(['LOWER(brands.name) LIKE :keyword OR LOWER(brands.name) LIKE :middle_keyword OR LOWER(brands.bn_name) LIKE :keyword OR LOWER(brands.bn_name) LIKE :middle_keyword', keyword: "#{keyword}%", middle_keyword: "% #{keyword}%"]).limit(2)
      products = Product
                   .publicly_visible
                   .b2c_products
                   .where(['LOWER(products.title) LIKE :keyword OR LOWER(products.title) LIKE :middle_keyword OR LOWER(products.bn_title) LIKE :keyword OR LOWER(products.bn_title) LIKE :middle_keyword', keyword: "#{keyword}%", middle_keyword: "% #{keyword}%"])
      if category.present?
        categories = []
        products = products.where("products.leaf_category_id = #{category.id}")
      else
        categories = Category
                       .b2c_categories
                       .visible_categories
                       .select(:id, :title, :bn_title, :slug)
                       .where(['LOWER(categories.title) LIKE :keyword OR LOWER(categories.title) LIKE :middle_keyword OR LOWER(categories.bn_title) LIKE :keyword OR LOWER(categories.bn_title) LIKE :middle_keyword', keyword: "#{keyword}%", middle_keyword: "% #{keyword}%"]).limit(2)
      end
      { categories: categories, brands: brands, products: products }
    end

    def record_search_key(key)
      search_keys = Rails.cache.fetch('products-searched-by-user') || []
      search_keys << key
      Rails.cache.write('products-searched-by-user', search_keys.uniq)
    rescue StandardError => error
      Rails.logger.info("Error while record product search key: #{error.message}")
    end
  end

  namespace 'homepage' do
    desc 'Get homepage navigation category.'
    route_setting :authentication, optional: true
    get '/navigation_categories' do
      category = menu_category Category.b2c_categories.where(parent_id: nil, home_page_visibility: true).order(:position).includes(:sub_categories)
      present :success, true
      present :status, HTTP_CODE[:OK]
      present :message, 'Successfully fetched categories.'
      present :data, category
    rescue StandardError => error
      Rails.logger.error "\n#{__FILE__}\nUnable to fetch categories due to: #{error.message}"
      return { success: false, status: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: 'Unable to fetch categories.', data: [] }
    end

    desc 'Get all product sliders.'
    params do
      optional :warehouse_id, type: Integer
    end
    route_setting :authentication, optional: true
    get '/product_sliders' do
      warehouse = Warehouse.find_by(id: params[:warehouse_id])
      aggregate = {}

      bestselling = Product.publicly_visible.get_product_list_by_product_type_for_b2c(Product::PRODUCT_TYPES[:bestselling], warehouse&.id)
      aggregate[:bestselling] = {
        title: bestselling[:title],
        slug: bestselling[:slug],
        bn_title: bestselling[:bn_title],
        product_list: get_homepage_product_list(bestselling[:product_list], @current_user, warehouse),
      }

      new_arrival = Product.publicly_visible.get_product_list_by_product_type_for_b2c(Product::PRODUCT_TYPES[:new_arrival], warehouse&.id)
      aggregate[:new_arrival] = {
        title: new_arrival[:title],
        slug: new_arrival[:slug],
        bn_title: new_arrival[:bn_title],
        product_list: get_homepage_product_list(new_arrival[:product_list], @current_user, warehouse),
      }

      trending = Product.publicly_visible.get_product_list_by_product_type_for_b2c(Product::PRODUCT_TYPES[:trending], warehouse&.id)
      aggregate[:trending] = {
        title: trending[:title],
        slug: trending[:slug],
        bn_title: trending[:bn_title],
        product_list: get_homepage_product_list(trending[:product_list], @current_user, warehouse),
      }

      daily_deals = Product.publicly_visible.get_product_list_by_product_type_for_b2c(Product::PRODUCT_TYPES[:daily_deals], warehouse&.id)
      aggregate[:daily_deals] = {
        title: daily_deals[:title],
        slug: daily_deals[:slug],
        bn_title: daily_deals[:bn_title],
        product_list: get_homepage_product_list(daily_deals[:product_list], @current_user, warehouse),
      }

      # Daily deals timer
      private_label = Product.publicly_visible.get_product_list_by_product_type_for_b2c(Product::PRODUCT_TYPES[:private_label], warehouse&.id)
      aggregate[:private_label] = {
        title: private_label[:title],
        slug: private_label[:slug],
        bn_title: private_label[:bn_title],
        product_list: get_homepage_product_list(private_label[:product_list], @current_user, warehouse),
      }

      featured = Product.publicly_visible.get_product_list_by_product_type_for_b2c(Product::PRODUCT_TYPES[:featured], warehouse&.id)
      aggregate[:featured] = {
        title: featured[:title],
        slug: featured[:slug],
        bn_title: featured[:bn_title],
        product_list: get_homepage_product_list(featured[:product_list], @current_user, warehouse),
      }

      bundles = Product.publicly_visible.get_product_list_by_product_type_for_b2c(Product::PRODUCT_TYPES[:bundles], warehouse&.id)
      aggregate[:bundles] = {
        title: bundles[:title],
        slug: bundles[:slug],
        bn_title: bundles[:bn_title],
        product_list: get_homepage_product_list(bundles[:product_list], @current_user, warehouse),
      }

      if aggregate[:trending].empty? &&
        aggregate[:new_arrival].empty? &&
        aggregate[:trending].empty? &&
        aggregate[:daily_deals].empty? &&
        aggregate[:private_label].empty? &&
        aggregate[:featured].empty? &&
        aggregate[:bundles].empty?
        {
          success: true,
          status: HTTP_CODE[:OK],
          message: 'No product in trending, best selling or new arrival list.',
          data: [],
        }
      else
        {
          success: true,
          status: HTTP_CODE[:OK],
          message: 'Successfully fetched product sliders.',
          data: aggregate,
        }
      end
    end

    desc 'Get all flash sales product.'
    route_setting :authentication, optional: true
    params do
      optional :warehouse_id, type: Integer
      use :pagination, per_page: 50
    end
    get '/flash_sales' do
      warehouse = Warehouse.find_by(id: params[:warehouse_id])
      flash_sales = Product.fetch_flash_sales
      if flash_sales.present?
        products = Product.order_by_weight_and_available_quantity(flash_sales[:products], warehouse&.id).uniq.first(10)
        success_response_with_json('Successfully fetched flash sale products.', HTTP_CODE[:OK],
                                   flash_sale(flash_sales[:flash_sale], @current_user, products, warehouse))
      else
        error!(failure_response_with_json('Flash sale products not found.', HTTP_CODE[:NOT_FOUND]),
               HTTP_CODE[:OK])
      end
    rescue StandardError => error
      Rails.logger.error "\n#{__FILE__}\nUnable to fetch due to: #{error.message}"
      error!(failure_response_with_json('Unable to fetch ', HTTP_CODE[:NO_CONTENT]), HTTP_CODE[:OK])
    end

    desc 'Get top selling products.'
    route_setting :authentication, optional: true
    params do
      optional :warehouse_id, type: Integer
      use :pagination, per_page: 50
    end
    get '/top_selling' do
      warehouse = Warehouse.find_by(id: params[:warehouse_id])
      products = Product.publicly_visible.b2c_products
      products = Product.order_by_weight_and_available_quantity(products, warehouse&.id, 'best-selling').uniq.first(10)
      data = {
        title: 'Top Sellers',
        bn_title: 'টপ সেলার',
        slug: 'best-selling',
        product_list: get_homepage_product_list(products, @current_user, warehouse),
      }
      success_response_with_json('Successfully fetched flash sale products.',
                                 HTTP_CODE[:OK], data)
    rescue StandardError => error
      Rails.logger.info "\n#{__FILE__}\nTop selling fetch failed due to: #{error.message}"
      error!(failure_response_with_json('Unable to fetch.', HTTP_CODE[:NO_CONTENT]), HTTP_CODE[:OK])
    end

    desc 'Get all products by category.'
    params do
      use :pagination, per_page: 50
      requires :category, type: String
      optional :warehouse_id, type: Integer
    end
    route_setting :authentication, optional: true
    get '/category_products' do
      warehouse = Warehouse.find_by(id: params[:warehouse_id])
      products = Product.publicly_visible.b2c_products.joins(:product_types).where(product_types: { title: Product::PRODUCT_TYPES[:"#{params[:category]}"] }) || []
      products = Product.order_by_weight_and_available_quantity(products, warehouse&.id)
      products ? { result: get_homepage_product_list(paginate(Kaminari.paginate_array(products)), @current_user, warehouse) } : []
    end

    desc 'Get homepage sliders.'
    route_setting :authentication, optional: true
    get '/sliders' do
      aggregate = {}
      aggregate[:slider_image] = to_slider_json Slide.all_homepage_slider_images
      aggregate[:selection_image] = to_slider_json Slide.all_selection_slider_images
      aggregate[:app_coupon_images] = to_slider_json Slide.all_app_coupon_slider_images
      aggregate[:web_coupon_images] = to_slider_json Slide.all_web_coupon_slider_images
      success_response_with_json('Slider fetched successfully.', HTTP_CODE[:OK], aggregate)
    rescue StandardError => error
      Rails.logger.error "\n#{__FILE__}\nUnable to fetch sliders due to: #{error.message}"
      failure_response_with_json('Unable to fetch sliders.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
    end

    desc 'Homepage product search.'
    params do
      use :pagination, per_page: 50
      requires :keyword, type: String
      optional :category_slug, type: String
      optional :warehouse_id, type: Integer
    end
    route_setting :authentication, optional: true
    get '/search' do
      category = nil
      warehouse = nil
      keyword = params[:keyword]
      if params[:warehouse_id].present?
        warehouse = Warehouse.find_by(id: params[:warehouse_id])
        unless warehouse
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.warehouse_not_found'),
                                            HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
        end
      end

      if params[:category_slug].present?
        category = Category.find_by(slug: params[:category_slug])
        unless category
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.category_not_found'),
                                            HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
        end
      end

      response_products = get_grid_product_list(
        paginate(Kaminari.paginate_array(homepage_products_fetch(category, keyword, warehouse&.id))), @current_user, warehouse
      )
      record_search_key(keyword)
      success_response_with_json(I18n.t('Ecom.success.messages.product_search_success'),
                                 HTTP_CODE[:OK], response_products)
    rescue StandardError => error
      Rails.logger.error "\n#{__FILE__}\nUnable to fetch search products due to: #{error.message}"
      error!(failure_response_with_json(I18n.t('Ecom.errors.messages.product_search_failed'),
                                        HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
    end

    desc 'Homepage user friendly product search.'
    params do
      requires :keyword, type: String
      optional :category_slug, type: String
      optional :warehouse_id, type: Integer
    end
    route_setting :authentication, optional: true
    get '/friendly_search' do
      category = nil
      warehouse = nil
      keyword = params[:keyword]
      if params[:warehouse_id].present?
        warehouse = Warehouse.find_by(id: params[:warehouse_id])
        unless warehouse
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.warehouse_not_found'),
                                            HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
        end
      end

      if params[:category_slug].present?
        category = Category.visible_categories.find_by(slug: params[:category_slug])
        unless category
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.category_not_found'),
                                            HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
        end
      end

      search_results = homepage_user_friendly_search(category, keyword, warehouse)
      products = Product.order_by_weight_and_available_quantity(search_results[:products], warehouse&.id).uniq.first(10)
      search_results[:products] = get_grid_product_list(products, @current_user, warehouse)
      record_search_key(keyword)
      success_response_with_json(I18n.t('Ecom.success.messages.product_search_success'),
                                 HTTP_CODE[:OK], search_results)
    rescue StandardError => error
      Rails.logger.error "\n#{__FILE__}\nUnable to fetch search products due to: #{error.message}"
      error!(failure_response_with_json(I18n.t('Ecom.errors.messages.product_search_failed'),
                                        HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
    end

    desc 'Shop by category.'
    route_setting :authentication, optional: true
    get '/categories' do
      shop_by_category = get_shop_by_category Category.unscoped.b2c_categories.where(parent_id: nil, home_page_visibility: true).order(:position)
      return { success: true, status: HTTP_CODE[:OK], message: 'Successfully fetched shop by category.', data: shop_by_category }
    rescue StandardError => error
      Rails.logger.error "\n#{__FILE__}\nUnable to fetch category list due to: #{error.message}"
      return { success: false, status: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: 'Unable to fetch category list.', data: [] }
    end

    desc 'Get all brand.'
    params do
      use :pagination, per_page: 50
    end
    route_setting :authentication, optional: true
    get '/all-brands' do
      brands = Brand.publicly_visible.joins(:logo_attachment).sort_by(&:brand_name_downcase)
      response = paginate(Kaminari.paginate_array(Ecommerce::V1::Entities::BrandShortInfos.represent(brands)))
      success_response_with_json(I18n.t('Ecom.success.messages.brands_fetch_successful'),
                                 HTTP_CODE[:OK], response)
    rescue StandardError => error
      Rails.logger.error "\n#{__FILE__}\nUnable to fetch brand list due to: #{error.message}"
      error!(failure_response_with_json(I18n.t('Ecom.errors.messages.brands_fetch_failed'),
                                        HTTP_CODE[:UNPROCESSABLE_ENTITY], []), HTTP_CODE[:OK])
    end

    desc 'Get list of shop by brand.'
    route_setting :authentication, optional: true
    get 'shop_by_brand' do
      brands = Brand.publicly_visible.includes(logo_attachment: :blob).where(homepage_visibility: true).sort_by(&:brand_name_downcase)
      success_response_with_json(I18n.t('Ecom.success.messages.brands_fetch_successful'),
                                 HTTP_CODE[:OK], Ecommerce::V1::Entities::BrandShortInfos.represent(brands))
    rescue StandardError => error
      Rails.logger.error "\n#{__FILE__}\nUnable to fetch brand list due to: #{error.message}"
      error!(failure_response_with_json(I18n.t('Ecom.errors.messages.brands_fetch_failed'),
                                        HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
    end

    resource :news_letters do
      desc 'Subscribe to newsLetter.'
      route_setting :authentication, optional: true
      post '/subscribe' do
        existing_news_letter = NewsLetter.find_by(email: params[:email], is_active: true)
        if existing_news_letter
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.already_subscribed'),
                                            HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:OK])
        end

        news_letter = NewsLetter.find_by_email(params[:email])
        if news_letter.present?
          news_letter.update!(is_active: true)
        else
          news_letter = NewsLetter.create!(email: params[:email])
        end
        # SubscribeMailer.create_subscribe_mail(params[:email], news_letter.token).deliver_now

        success_response_with_json(I18n.t('Ecom.success.messages.successfully_subscribed'), HTTP_CODE[:OK])
      rescue StandardError => error
        Rails.logger.error "\n#{__FILE__}\nUnable to create newsLetter due to: #{error.message}"
        error!(failure_response_with_json(I18n.t('Ecom.errors.messages.subscription_failed'),
                                          HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
      end

      desc 'Unsubscribe to newsLetter.'
      # TODO: Facing a problem with find_by. I have two email, 1st: rakib@gmail.com, 2nd: rakib123@gmail.com.
      # I want to unsubscribe 2nd email's newsLetter. But each time 1st newsLetter is being unsubscribed.
      route_setting :authentication, optional: true
      put '/unsubscribe' do
        news_letter = NewsLetter.find_by(token: params[:token])
        unless news_letter
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.newsLetter_not_found'),
                                            HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
        end

        already_unsubscribed = NewsLetter.find_by(token: params[:token], is_active: false)
        if already_unsubscribed.present?
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.already_unsubscribed'),
                                            HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
        end

        news_letter.update!(is_active: false)
        success_response_with_json(I18n.t('Ecom.success.messages.unsubscribe_successful'), HTTP_CODE[:OK])
      rescue StandardError => error
        Rails.logger.error "\n#{__FILE__}\nUnable to unsubscribed newsLetter due to: #{error.message}"
        error!(failure_response_with_json(I18n.t('Ecom.errors.messages.unsubscribed_failed'),
                                          HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
      end
    end
  end
end
