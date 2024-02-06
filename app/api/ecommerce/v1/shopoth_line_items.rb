# frozen_string_literal: true

module Ecommerce
  module V1
    class ShopothLineItems < Ecommerce::Base
      helpers do
        # FOR FINDING CURRENT CART
        def current_cart(cart_id)
          @cart = Cart.find(cart_id)
        rescue ActiveRecord::RecordNotFound
          @cart = Cart.new
          @cart.save
        end
      end

      resource :shopoth_line_items do
        # INDEX
        desc 'Return list of line_items'
        route_setting :authentication, optional: true
        get do
          ShopothLineItem.all
        rescue StandardError => ex
          error!("Cannot show due to #{ex.message}")
        end

        desc 'Get details of a specific Shopoth line items.'
        get ':id' do
          line_item = @current_user.shopoth_line_items.find_by(id: params[:id])
          unless line_item
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.item_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          response = Ecommerce::V1::Entities::LineItemForReviews.represent(line_item)
          success_response_with_json(I18n.t('Ecom.success.messages.line_item_details_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch item's details due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.line_item_details_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        # Create
        desc 'Create line_item'
        params do
          requires :variant_id, type: Integer
          requires :cart_id, type: Integer
          optional :quantity, type: Integer
        end
        route_setting :authentication, optional: true
        post do
          current_cart(params[:cart_id])
          product = Variant.find(params[:variant_id])
          if product
            shopoth_line_item = @cart.add_product(product)
            { shopoth_line_item: shopoth_line_item } if shopoth_line_item.save
          else
            respond_with_json('Something went wrong!', 500)
          end
        rescue StandardError => ex
          error!("Cannot create entity due to #{ex.message}")
        end

        # add by one
        desc 'Add by one quantity'
        route_setting :authentication, optional: true
        route_param :id do
          put '/add-one' do
            shopoth_line_item = ShopothLineItem.find(params[:id])
            if shopoth_line_item
              shopoth_line_item.quantity += 1
              shopoth_line_item.save
              { cart_id: shopoth_line_item.cart_id }
            else
              respond_with_json('Something went wrong!', 500)
            end
          rescue StandardError => ex
            error!("Cannot increase due to #{ex.message}")
          end
        end

        # decrease by one
        desc 'Decrease by one quantity'
        route_setting :authentication, optional: true
        route_param :id do
          put '/dec-one' do
            shopoth_line_item = ShopothLineItem.find(params[:id])
            if shopoth_line_item.quantity > 1
              shopoth_line_item.quantity -= 1
              shopoth_line_item.save
              { cart_id: shopoth_line_item.cart_id }
            else
              respond_with_json('Must keep one product', 400)
            end
          rescue StandardError => ex
            error!("Cannot decrease due to #{ex.message}")
          end
        end

        # delete line_item
        desc 'Delete a specific Line_item'
        route_setting :authentication, optional: true
        route_param :id do
          delete do
            if shopoth_line_item = ShopothLineItem.find(params[:id])
              shopoth_line_item.destroy
              respond_with_json('Deleted', 200)
            else
              respond_with_json('Not Deleted', 500)
            end
          rescue StandardError => ex
            error!("Cannot delete due to #{ex.message}")
          end
        end
      end
    end
  end
end

