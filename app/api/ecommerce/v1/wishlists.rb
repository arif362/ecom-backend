# frozen_string_literal: true

module Ecommerce
  module V1
    class Wishlists < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::WishlistSerializer
      helpers Ecommerce::V1::Serializers::HomepageSerializer

      resource :wishlists do
        desc "Get a specific user's wishlists."
        params do
          use :pagination, per_page: 50
          optional :warehouse_id, type: Integer
        end
        get do
          warehouse = Warehouse.find_by(id: params[:warehouse_id])
          products = Product.order_by_weight_and_available_quantity(
            Product.includes(:brand).joins(:wishlists).where('wishlists.user_id = ?', @current_user.id), warehouse&.id
          )
          # TODO: Need to Optimize Query
          response = get_homepage_product_list(
            paginate(Kaminari.paginate_array(products)), @current_user, warehouse
          )
          success_response_with_json(I18n.t('Ecom.success.messages.user_wishlists_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch your wishlist's products due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_wishlists_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc "Add product to a specific user's Wishlist."
        params do
          requires :product_id, type: Integer
        end

        post do
          product = Product.find_by(id: params[:product_id])
          unless product
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.variant_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          current_wishlist_item = @current_user.wishlists.find_by(product: product)
          if current_wishlist_item
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.variant_is_already_in_wishlist'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          @current_user.wishlists.create!(product: product)
          success_response_with_json(I18n.t('Ecom.success.messages.variant_add_to_wishlist_successful'),
                                     HTTP_CODE[:CREATED])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to add this product to your wishlist due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.variant_add_to_wishlist_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Delete an item in wishlist.'
        delete ':id' do
          wishlist = @current_user.wishlists.find_by(product_id: params[:id])
          unless wishlist
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.wishlists_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          wishlist.destroy!
          success_response_with_json(I18n.t('Ecom.success.messages.user_wishlists_delete_successful'),
                                     HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete wishlist due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.wishlists_delete_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
