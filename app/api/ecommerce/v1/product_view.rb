# frozen_string_literal: true

class Ecommerce::V1::ProductView < Ecommerce::Base
  helpers Ecommerce::V1::Serializers::ProductSerializer

  helpers do
    def get_attributes(variants)
      variants = variants.includes(product_attribute_values: :product_attribute)
      variants.map do |variant|
        variant.product_attribute_values.map do |prod_attr_value|
          {
            product_attribute_name: prod_attr_value&.product_attribute&.name,
            product_attribute_value_id: prod_attr_value.id,
            product_attribute_value_name: prod_attr_value.value,
          }
        end
      end.flatten.uniq.group_by { |h| h[:product_attribute_name] }
    end

    def product_attributes(attribute_variants)
      product_attribute = attribute_variants
      product_attribute.map do |key, value|
        {
          product_attribute_name: key,
          product_attribute_values: value.map { |h| { id: h[:product_attribute_value_id], value: h[:product_attribute_value_name] } },
        }
      end
    end

    def all_reviews(product)
      approved_reviews = approved_reviews(product)
      rating_count = approved_reviews&.size
      comment_count = approved_reviews&.pluck(:description)&.reject(&:blank?)&.size
      star_count = { '5': 0, '4': 0, '3': 0, '2': 0, '1': 0 }
      if approved_reviews.blank?
        rating_avg = 0
        recommended = 0
        recommended_percent = 0
      else
        rating_avg = approved_reviews.average(:rating)&.round(1).to_f || 0
        recommended = approved_reviews.where(is_recommended: true)&.size
        recommended_percent = rating_count.positive? ? ((recommended.to_f / rating_count) * 100).round(1) : 0
        specified_star_count_hash = approved_reviews.group(:rating)&.count
        specified_star_count_hash.each do |k, v|
          star_count[k] = v
        end
      end
      {
        rating_count: rating_count,
        rating_avg: rating_avg,
        comment_count: comment_count,
        recommended: recommended,
        recommended_percent: recommended_percent,
        specified_star_count: star_count,
      }
    end

    def approved_reviews(product)
      @approved_reviews ||= Review.where(reviewable_type: 'Variant', reviewable_id: product.variants.ids, is_approved: true).where.not(description: ['', nil])
    end
  end

  namespace 'products' do
    route_param :id do
      desc 'Product Details.'
      params do
        optional :warehouse_id, type: Integer
      end
      route_setting :authentication, optional: true
      get do
        warehouse = Warehouse.find_by(id: params[:warehouse_id])
        product = if warehouse.present?
                    product = warehouse.products&.publicly_visible&.find_by(slug: params[:id])
                    product.nil? ? Product.get_product(params[:id]) : product
                  else
                    Product.get_product(params[:id])
                  end

        unless product
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.product_not_found'),
                                            HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
        end
        product&.record_visited(env['REMOTE_ADDR'], @current_user)

        data = Ecommerce::V1::Entities::ProductView.represent(
          product, current_user: @current_user, warehouse: warehouse
        )
        success_response_with_json('Successfully fetched product details.', HTTP_CODE[:OK], data)
      rescue StandardError => error
        Rails.logger.error "\n#{__FILE__}\nUnable to fetch product details due to: #{error.message}"
        error!(failure_response_with_json('Unable to fetch product details.',
                                          HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
      end

      desc 'Get review list of a product.'
      route_setting :authentication, optional: true
      get '/reviews' do
        product = Product.find_by(slug: params[:id])
        unless product
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.product_not_found'),
                                            HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
        end

        reviews = Ecommerce::V1::Entities::Reviews.represent(approved_reviews(product))
        all_reviews = all_reviews(product)
        response = { all_reviews: all_reviews, reviews: reviews }
        success_response_with_json(I18n.t('Ecom.success.messages.product_reviews_fetch_successful'),
                                   HTTP_CODE[:OK], response)
      rescue StandardError => error
        Rails.logger.error "\n#{__FILE__}\nUnable to fetch reviews due to: #{error.message}"
        error!(failure_response_with_json(I18n.t('Ecom.errors.messages.product_reviews_fetch_failed'),
                                          HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
      end
    end
  end
end
