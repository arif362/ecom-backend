module ShopothPartner
  module V1
    class Categories < ShopothPartner::Base
      include Grape::Kaminari

      helpers do
        def category_products
          category = Category.find(params[:id])
          warehouse = @current_partner&.route&.warehouse
          business_types = check_b2b? ? %w(both b2b) : %w(both b2c)
          if warehouse
            warehouse.products&.publicly_visible&.joins(:categories).where(categories: { id: category.id }, business_type: business_types).
              where('warehouse_variants.available_quantity > ?', 0).uniq
          else
            category.products.where(business_type: business_types).uniq
          end
        end

        def apply_filter(params, products)
          if params[:brands].present?
            products = products.where(brand_id: params[:brands])
          end
          if params[:max_price].present? && params[:min_price].present?
            min_price = params[:min_price]
            max_price = params[:max_price]
            products = products.joins(:variants).where('variants.price_consumer >= ? AND variants.price_consumer <= ?', min_price, max_price)
          end
          products
        end
      end

      resource :category do
        params do
          use :pagination, per_page: 10
        end

        desc 'Get all product in a category.'
        route_param :id do
          get do
            params do
              optional :sort_by, type: String
              optional :direction, type: String, default: 'asc', values: %w(asc desc)
            end

            products = category_products

            sort_by = params[:sort_by]
            direction = params[:direction]
            if sort_by && direction
              products = Product.sort(products, sort_by, direction, @business_type)
            end

            warehouse = @current_partner&.route&.warehouse
            # TODO: Need to Optimize Query
            if @locale == :bn
              ShopothPartner::V1::Entities::BnCategoryProducts.represent(
                paginate(Kaminari.paginate_array(products)), warehouse: warehouse, b2b: check_b2b?
              )
            else
              ShopothPartner::V1::Entities::CategoryProducts.represent(
                paginate(Kaminari.paginate_array(products)), warehouse: warehouse, b2b: check_b2b?
              )
            end
          rescue StandardError => error
            Rails.logger.error "#{__FILE__} \nUnable to fetch category products due to: #{error.message}"
            error!(respond_with_json(I18n.t('Partner.errors.messages.category_products_fetch_failed'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Filter Products based on a category'
          get '/filter' do
            params do
              optional :min_price, type: String
              optional :max_price, type: String
              optional :brands, type: Array
            end

            products = category_products
            filtered_products = apply_filter(params, products)
            # TODO: Need to Optimize Query
            if @locale == :bn
              ShopothPartner::V1::Entities::BnCategoryProducts.represent(
                paginate(Kaminari.paginate_array(filtered_products)),
              )
            else
              ShopothPartner::V1::Entities::CategoryProducts.represent(
                paginate(Kaminari.paginate_array(filtered_products)),
              )
            end
          rescue StandardError => error
            Rails.logger.error "#{__FILE__} \nUnable to fetch category products due to: #{error.message}"
            error!(respond_with_json(I18n.t('Partner.errors.messages.category_products_fetch_failed'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Filter Products based on a category.'
          get '/brands' do
            products = category_products
            Brand.where(id: products.uniq.pluck(:brand_id)).pluck(:name)
          rescue StandardError => error
            Rails.logger.error "#{__FILE__} \nUnable to fetch category products due to: #{error.message}"
            error!(respond_with_json(I18n.t('Partner.errors.messages.category_products_fetch_failed'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
