# frozen_string_literal: true

module Ecommerce
  module V1
    class Brands < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::ProductSerializer
      resource :brands do
        desc 'Fetch own brand list.'
        params do
          use :pagination, per_page: 50
        end
        route_setting :authentication, optional: true
        get '/own' do
          brands = Brand.where(is_own_brand: true)
          # TODO: Need to Optimize Query
          data = Ecommerce::V1::Entities::BrandShortInfos.represent(paginate(Kaminari.paginate_array(brands)), current_user: @current_user)
          present :success, true
          present :status, HTTP_CODE[:OK]
          present :message, 'Successfully fetched own brand list.'
          present :data, data
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch own brands due to: #{error.message}"
          return { success: false, status: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: 'Unable to fetch own brand list.', data: [] }
        end

        desc 'Get a specific Brand.'
        route_setting :authentication, optional: true
        get ':slug' do
          brand = Brand.find_by(slug: params[:slug])
          unless brand
            error!(failure_response_with_json('Brand not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          brand = Ecommerce::V1::Entities::Brands.represent(brand, current_user: @current_user)
          success_response_with_json('Brand fetched successfully', HTTP_CODE[:OK], brand)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch Brand details due to: #{error.message}"
          failure_response_with_json('Unable to fetch Brand details.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Follow a Brand.'
        post ':slug/follow' do
          brand = Brand.find_by(slug: params[:slug])
          unless brand
            error!(failure_response_with_json('Brand not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          brand_following = @current_user.brand_followings.find_by(brand: brand)

          if brand_following.blank?
            @current_user.brand_followings.create(brand: brand)
            respond_with_json(I18n.t('Ecom.success.messages.brand_follow_successful'), HTTP_CODE[:OK])
          else
            respond_with_json(I18n.t('Ecom.errors.messages.brand_already_followed'), HTTP_CODE[:OK])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to follow Brand due to: #{error.message}"
          failure_response_with_json(I18n.t('Ecom.errors.messages.brand_follow_failed'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Unfollow a Brand.'
        delete ':slug/unfollow' do
          brand = Brand.find_by(slug: params[:slug])
          unless brand
            error!(failure_response_with_json('Brand not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          brand_following = @current_user.brand_followings.find_by(brand: brand)

          if brand_following.present?
            brand_following.delete
            respond_with_json(I18n.t('Ecom.success.messages.brand_unfollow_successful'), HTTP_CODE[:OK])
          else
            respond_with_json(I18n.t('Ecom.errors.messages.brand_follow_not_found'), HTTP_CODE[:NOT_FOUND])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to unfollow Brand due to: #{error.message}"
          failure_response_with_json(I18n.t('Ecom.errors.messages.brand_unfollow_failed'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get brand categories.'
        route_setting :authentication, optional: true
        params do
          use :pagination, per_page: 10
        end
        get ':slug/categories' do
          brand = Brand.find_by(slug: params[:slug])
          unless brand
            error!(failure_response_with_json('Brand not found.', HTTP_CODE[:NOT_FOUND], []), HTTP_CODE[:OK])
          end

          categories = Category.b2c_categories.joins(products: :brand).where("brands.slug = '#{brand.slug}' AND products.leaf_category_id = categories.id").distinct
          # TODO: Need to Optimize Query
          response = if @request_source == :app
                       Ecommerce::V1::Entities::BrandCategory.represent(
                         paginate(Kaminari.paginate_array(categories.order(position: :desc))),
                       )
                     else
                       Ecommerce::V1::Entities::BrandCategory.represent(categories.order(position: :desc))
                     end
          success_response_with_json('Brand Categories fetched successfully', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to get Brand categories due to: #{error.message}"
          failure_response_with_json('Unable to get Brand categories.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Filter brand products.'
        route_setting :authentication, optional: true
        params do
          use :pagination, per_page: 50
          optional :category_slugs, type: Array[String]
          optional :product_attribute_ids, type: Array[Integer]
          optional :price_range, type: Hash do
            requires :min, type: Integer
            requires :max, type: Integer
          end
          optional :product_type_ids, type: Array[Integer]
          optional :keywords, type: Array[String]
        end
        get ':slug/filter' do
          brand = Brand.find_by(slug: params[:slug])
          unless brand
            error!(failure_response_with_json('Brand not found.', HTTP_CODE[:NOT_FOUND], []), HTTP_CODE[:OK])
          end
          warehouse = Warehouse.find_by(id: params[:warehouse_id])
          products = brand&.products&.publicly_visible&.b2c_products&.includes(:variants, :root_category, :product_types, main_image_attachment: :blob)

          if params[:keywords].present?
            keywords = params[:keywords].map { |word| "%#{word.downcase}%" }
            products = products.where('LOWER(products.title) LIKE :keywords OR LOWER(products.bn_title) LIKE :keywords', keywords: keywords)
          end
          if params[:category_slugs].present?
            products = products.joins(:categories).where(categories: { slug: params[:category_slugs] })
          end
          if params[:product_attribute_ids].present?
            products = products.joins(:product_attribute_values).where(product_attribute_values: { id: params[:product_attribute_ids] })
          end
          if params[:price_range].present?
            products = products.joins(:variants).where(variants: { effective_mrp: params[:price_range][:min]..params[:price_range][:max] }).distinct(:id)
          end
          if params[:product_type_ids].present?
            products = products.joins(:product_types).where(product_types: { id: params[:product_type_ids] })
          end

          products = Product.order_by_weight_and_available_quantity(products, warehouse&.id)
          # TODO: Need to Optimize Query
          response = get_grid_product_list(paginate(Kaminari.paginate_array(products.uniq)), @current_user, warehouse)
          success_response_with_json('Brand products fetched successfully', HTTP_CODE[:OK],
                                     response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to get Brand products due to: #{error.message}"
          failure_response_with_json('Unable to get Brand products.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
