module ShopothPartner
  module V1
    class Products < ShopothPartner::Base
      helpers do
        def select_products(warehouse, search_key)
          warehouse.products&.publicly_visible&.includes(:variants, :brand, :main_image_attachment, :images_attachments).
            where(business_type: business_types).
            where('warehouse_variants.available_quantity > 0 AND (LOWER(products.title) LIKE :key OR LOWER(products.bn_title) LIKE :key)', key: "#{search_key&.downcase}%").
            uniq.
            sample(10)
        end

        def business_types
          return %w(b2b both) if check_b2b?

          %w(b2c both)
        end
      end

      resource :product do
        desc 'Product Categories.'
        get 'categories' do
          categories = Category.where(parent_id: nil, business_type: business_types).order(:position)
          if @locale == :bn
            ShopothPartner::V1::Entities::BnCategories.represent(categories, is_b2b: check_b2b?)
          else
            ShopothPartner::V1::Entities::Categories.represent(categories, is_b2b: check_b2b?)
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to fetch categories due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.category_fetch_failed'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Product Details.'
        route_param :id do
          get 'details' do
            product = Product.publicly_visible.find(params[:id])
            if @locale == :bn
              present product,
                      with: ShopothPartner::V1::Entities::BnPartnerProducts,
                      warehouse: @current_partner&.route&.warehouse,
                      b2b: check_b2b?
            else
              present product,
                      with: ShopothPartner::V1::Entities::PartnerProducts,
                      warehouse: @current_partner&.route&.warehouse,
                      b2b: check_b2b?,
                      language: 'en'
            end
          rescue StandardError => error
            Rails.logger.error "#{__FILE__} \nUnable to fetch product details due to: #{error.message}"
            error!(respond_with_json(I18n.t('Partner.errors.messages.product_details_fetch_failed'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Search product by title.'
        params do
          requires :title, type: String
        end
        get '/search' do
          products = select_products(@current_partner&.route&.warehouse, params[:title])
          ShopothPartner::V1::Entities::ProductDetails.represent(products,
                                                                 language: request.headers['Language-Type'])
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to fetch products with title: #{params[:title]} due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.product_fetch_failed'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end
      end
    end
  end
end
