# frozen_string_literal: true

module Ecommerce
  module V1
    class Recommendations < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::ProductSerializer

      namespace 'recommendations' do
        desc 'Get similar products.'
        params do
          requires :product_slug, type: String
        end
        route_setting :authentication, optional: true
        get 'similar_products' do
          product = Product.find_by(slug: params[:product_slug])
          similarities = RecommendationEngine::ProductRecommender.new.similarities_for("product-#{product.id}", limit: 10)
          similar_products = Product.where(id: (similarities.map { |i| i.gsub('product-', '').to_i }))
          products = Product.order_by_weight_and_available_quantity(similar_products)
          success_response_with_json('Successfully fetched product recommendations', HTTP_CODE[:OK],
                                     get_grid_product_list(products, @current_user))
        rescue StandardError => error
          respond_with_json("Something went wrong due to #{error.message}", 500)
        end

        desc 'Get similar picked products.'
        params do
          requires :product_id, type: Integer
        end
        route_setting :authentication, optional: true
        get 'bought_together' do
          product = Product.find params[:product_id]
          similarities = RecommendationEngine::ProductRecommender.new.similarities_for("customer-order-#{product.id}", limit: 10)
          similar_products = Product.where(id: (similarities.map { |i| i.gsub('customer-order-', '').to_i }))
          products = Product.order_by_weight_and_available_quantity(similar_products)
          {
            success: true,
            status_code: 200,
            message: 'Successfully fetched bought together product recommendations',
            data: get_grid_product_list(products, @current_user),
          }
        rescue StandardError => error
          respond_with_json("Something went wrong due to #{error.message}", 500)
        end

        desc 'Get recommendations for you.'
        route_setting :authentication, optional: true
        get 'for_you' do
          max_product = 100
          limit = 10
          similar_product_ids = []

          if @current_user.present?
            # based on users own customer order
            product_ids = @current_user.shopoth_line_items.map { |line_item| line_item&.variant&.product_id }&.uniq&.compact
            product_ids.each do |product_id|
              similarities = RecommendationEngine::ProductRecommender.new.similarities_for("product-#{product_id}", limit: max_product)
              similar_product_ids << product_id
              similar_product_ids += similarities.map { |i| i.gsub('product-', '').to_i }
              break if similar_product_ids.count >= max_product
            end

            # based on user wishlist
            product_ids = @current_user.wishlists.map { |wishlist| wishlist&.product_id }&.uniq&.compact
            product_ids.each do |product_id|
              similarities = RecommendationEngine::ProductRecommender.new.similarities_for("product-#{product_id}", limit: limit)
              similar_product_ids << product_id
              similar_product_ids += similarities.map { |i| i.gsub('product-', '').to_i }
              break if similar_product_ids.count >= max_product
            end
          end

          # according to user preferences
          key = @current_user&.id || env['REMOTE_ADDR']
          product_list = Rails.cache.fetch("products-visited-by-#{key}") || {}
          product_list.each do |id, visit_count|
            similarities = RecommendationEngine::ProductRecommender.new.similarities_for("product-#{id}", limit: limit)
            similar_product_ids << id
            similar_product_ids += similarities.map { |i| i.gsub('product-', '').to_i }
            break if similar_product_ids.count >= max_product
          end

          # based on product search key
          search_keys = Rails.cache.fetch('products-searched-by-user') || []
          result = {}
          search_keys.uniq.each { |element| result[element] = search_keys.count(element) }
          result = result.sort_by { |_key, value| value }.reverse
          result[0..4].each do |key, visit_count|
            product = Product.where('title LIKE :identifier OR bn_title LIKE :identifier', identifier: "%#{key}%").first
            similarities = RecommendationEngine::ProductRecommender.new.similarities_for("product-#{product&.id}", limit: limit)
            similar_product_ids << product&.id
            similar_product_ids += similarities.map { |i| i.gsub('product-', '').to_i }
            break if similar_product_ids.count >= max_product
          end
          # own brand products
          brands = Brand.where(is_own_brand: true).order('RANDOM()')
          brands.each do |brand|
            rand_product = brand.products&.order('RANDOM()')&.first
            similarities = RecommendationEngine::ProductRecommender.new.similarities_for("brand-#{rand_product&.id}", limit: limit)
            similar_product_ids += similarities.map { |i| i.gsub('brand-', '').to_i }
            break if similar_product_ids.count >= max_product
          end

          # add best selling products
          top_selling = Product.publicly_visible.where('sell_count > 0').order(sell_count: :desc).limit(10)
          similar_product_ids += top_selling.pluck(:id)
          similar_products = Product.publicly_visible.where(id: similar_product_ids.compact.sample(20))
          products = Product.order_by_weight_and_available_quantity(similar_products)
          {
            success: true,
            status_code: 200,
            message: 'Successfully fetched recommendations for you',
            data: get_grid_product_list(products, @current_user),
          }
        rescue StandardError => error
          respond_with_json("Something went wrong due to #{error.message}", 500)
        end

        desc 'Get product suggestions for brand.'
        params do
          requires :brand_id, type: String
        end
        route_setting :authentication, optional: true
        get 'brand_products' do
          brand = Brand.find params[:brand_id]
          rand_product = brand.products&.order('RANDOM()')&.first
          similarities = RecommendationEngine::ProductRecommender.new.similarities_for("brand-#{rand_product&.id}", limit: 10)
          similar_products = Product.where(id: (similarities.map { |i| i.gsub('brand-', '').to_i }))
          products = Product.order_by_weight_and_available_quantity(similar_products)
          {
            success: true,
            status_code: 200,
            message: 'Successfully fetched product recommendations',
            data: get_grid_product_list(products, @current_user),
          }
        rescue StandardError => error
          respond_with_json("Something went wrong due to #{error.message}", 500)
        end

        desc 'Get product suggestions for user_preference.'
        route_setting :authentication, optional: true
        get 'user_preference' do
          key = @current_user&.id || env['REMOTE_ADDR']
          product_list = Rails.cache.fetch("products-visited-by-#{key}") || {}
          recommended_product_ids = []
          product_list.each do |id, visit_count|
            similarities = RecommendationEngine::ProductRecommender.new.similarities_for("product-#{id}", limit: 10)
            similar_product_ids = similarities.map { |i| i.gsub('product-', '').to_i }
            recommended_product_ids << similar_product_ids
            break if recommended_product_ids.count >= 10
          end
          recommended_products = Product.where(id: recommended_product_ids)
          products = Product.order_by_weight_and_available_quantity(recommended_products)
          {
            success: true,
            status_code: 200,
            message: 'Successfully fetched product recommendations',
            data: get_grid_product_list(products, @current_user),
          }
        rescue StandardError => error
          respond_with_json("Something went wrong due to #{error.message}", 500)
        end

        desc 'Get product suggestions for own brand.'
        route_setting :authentication, optional: true
        get 'own_brand_products' do
          brands = Brand.where(is_own_brand: true).order('RANDOM()')
          recommended_product_ids = []
          brands.each do |brand|
            rand_product = brand.products&.order('RANDOM()')&.first
            similarities = RecommendationEngine::ProductRecommender.new.similarities_for("brand-#{rand_product&.id}", limit: 10)
            similar_product_ids = similarities.map { |i| i.gsub('brand-', '').to_i }
            recommended_product_ids << similar_product_ids
            break if recommended_product_ids.count >= 10
          end
          recommended_products = Product.where(id: recommended_product_ids)
          products = Product.order_by_weight_and_available_quantity(recommended_products)
          {
            success: true,
            status_code: 200,
            message: 'Successfully fetched product recommendations',
            data: get_grid_product_list(products, @current_user),
          }
        rescue StandardError => error
          respond_with_json("Something went wrong due to #{error.message}", 500)
        end
      end
    end
  end
end
