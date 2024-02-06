module Ecommerce
  module V1
    class SearchItems < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::ProductSerializer
      namespace 'search' do
        desc 'Search products'
        route_setting :authentication, optional: true
        params do
          use :pagination, per_page: 20
        end
        get '/products/:keyword' do
          products = Product.publicly_visible.search_with_title(params[:keyword])
          # TODO: Need to Optimize Query
          response = paginate(Kaminari.paginate_array(get_grid_product_list(products, @current_user)))
          success_response_with_json(I18n.t('Ecom.success.messages.product_search_success'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch products due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.product_search_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        # Don't remove this API. It's for ecom related search.
        desc 'Search related keys'
        route_setting :authentication, optional: true
        params do
          use :pagination, per_page: 20
        end
        get '/related_keys/:key' do
          search_items = Search.search_related_keys(params[:key])
          keys = search_items.pluck(:search_key)
          keys.delete(params[:key]) || []

          success_response_with_json(I18n.t('Ecom.success.messages.key_search_success'),
                                     HTTP_CODE[:OK], keys.last(20).sample(10))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch products due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.key_search_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
