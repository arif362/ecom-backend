# frozen_string_literal: true

module Ecommerce
  module V1
    class Carts < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::CartShowSerializer
      helpers do
        def quantity_available?(quantity, variant, warehouse)
          available_quantity = WarehouseVariant.find_by(variant: variant, warehouse: warehouse)&.available_quantity || 0
          available_quantity >= quantity
        end

        def current_quantity
          line_item = @current_cart.shopoth_line_items.find_by(variant: @variant)
          line_item ? line_item.quantity + params[:quantity] : params[:quantity]
        end

        def error_message!
          error!({ unavailable: 'Can not add due to unavailable quantity' })
        end

        def current_item_delete(current_cart, current_item, warehouse)
          if current_item.customer_order.present? && current_item.cart.present?
            cart = current_item.cart
            current_cart.samples.update_all(cart_id: nil) if current_item.samples.present?
            current_item.update!(cart_id: nil)
            cart.update_cart_attr(user_domain, warehouse, @current_user)
          else
            current_item.destroy!
            current_cart.coupon_applicable?('organic')
            current_cart.update_cart_attr(user_domain, warehouse, @current_user)
          end
        end
      end

      resource :carts do
        # create a cart and populate with shopoth_line_items
        desc 'Create a cart.'
        params do
          requires :warehouse_id, type: Integer
          requires :variant_id, type: Integer
          requires :quantity, type: Integer, values: ->(v) { v.positive? }
        end
        route_setting :authentication, optional: true
        post do
          warehouse = Warehouse.find_by(id: params[:warehouse_id])
          unless warehouse
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.warehouse_not_found'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          variant = warehouse.variants.find_by(id: params[:variant_id])
          unless variant && variant.product.present?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.variant_not_found'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          cart = if @current_user.present? && @current_user.cart.present?
                   @current_user.cart
                 else
                   Cart.create!
                 end

          qty = cart.shopoth_line_items.find_by(variant: variant)&.quantity || 0
          unless quantity_available?(params[:quantity] + qty, variant, warehouse) == true
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.unavailable_quantity'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          quantity_present = variant.product.validate_products_max_limit(cart.shopoth_line_items, params[:quantity])
          unless quantity_present[:success]
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.max_limit_exceed'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          item = cart.add_cart(variant, params[:quantity], warehouse.id)
          if item[:success] == false
            error!(failure_response_with_json(item[:error],
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          cart.update_cart_attr(user_domain, warehouse, @current_user)
          response = Ecommerce::V1::Entities::Carts.represent(cart, warehouse: warehouse, list: true)
          success_response_with_json(I18n.t('Ecom.success.messages.cart_creation_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create cart due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.cart_creation_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        route_param :id do
          before do
            @warehouse = Warehouse.find_by(id: params[:warehouse_id])
            unless @warehouse
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.warehouse_not_found'),
                                                HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end

            @current_cart = Cart.find_by(id: params[:id])
            unless @current_cart
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.cart_not_found'),
                                                HTTP_CODE[:NOT_FOUND], {}), HTTP_CODE[:OK])
            end
          end

          desc 'Get all shopoth_line_item in cart.'
          route_setting :authentication, optional: true
          get do
            @current_cart.validate_cart_items_price(@warehouse)
            @current_cart.update_cart_attr(user_domain, @warehouse, @current_cart.user)
            response = Ecommerce::V1::Entities::Carts.represent(
              @current_cart, warehouse: @warehouse, list: true
            )
            success_response_with_json(I18n.t('Ecom.success.messages.cart_details_fetch_successful'),
                                       HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch details of cart due to: #{error.message}"
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.cart_details_fetch_failed'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:OK])
          end

          resource :shopoth_line_items do
            desc 'Add product to cart.'
            params do
              requires :variant_id, type: Integer
              requires :quantity, type: Integer, values: ->(v) { v.positive? }
              requires :warehouse_id, type: Integer
            end
            route_setting :authentication, optional: true
            put do
              @variant = @warehouse.variants.find_by(id: params[:variant_id])
              unless @variant && @variant.product.present?
                error!(failure_response_with_json(I18n.t('Ecom.errors.messages.variant_not_found'),
                                                  HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
              end

              if quantity_available?(current_quantity, @variant, @warehouse) == false
                error!(failure_response_with_json(I18n.t('Ecom.errors.messages.unavailable_quantity'),
                                                  HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
              end

              quantity_present = @variant.product.validate_products_max_limit(@current_cart.shopoth_line_items, params[:quantity])
              unless quantity_present[:success]
                error!(failure_response_with_json(I18n.t('Ecom.errors.messages.max_limit_exceed'),
                                                  HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
              end

              item = @current_cart.add_cart(@variant, params[:quantity], @warehouse.id)
              if item[:success] == false
                error!(failure_response_with_json(item[:error], HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                       HTTP_CODE[:OK])
              end

              @current_cart.update_cart_attr(user_domain, @warehouse, @current_user)
              response = Ecommerce::V1::Entities::Carts.represent(
                @current_cart, warehouse: @warehouse, list: true
              )
              success_response_with_json(I18n.t('Ecom.success.messages.line_item_update_successful'),
                                         HTTP_CODE[:OK], response)
            rescue StandardError => error
              Rails.logger.error "\n#{__FILE__}\nUnable to update line item due to: #{error.message}"
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.line_item_update_failed'),
                                                HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
            end

            desc 'Remove shopoth line item from the cart.'
            route_param :shopoth_line_item_id do
              route_setting :authentication, optional: true
              delete do
                shopoth_line_items = @current_cart.shopoth_line_items
                current_item = shopoth_line_items.find_by(id: params[:shopoth_line_item_id])
                unless current_item
                  error!(failure_response_with_json(I18n.t('Ecom.errors.messages.cart_item_not_found'),
                                                    HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
                end

                if current_item.sample_for.present?
                  error!(failure_response_with_json(I18n.t('Ecom.errors.messages.sample_item_error'),
                                                    HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
                end

                response = if shopoth_line_items.size == 1
                             @current_cart.destroy_with_shopoth_line_items
                             {}
                           else
                             current_item_delete(@current_cart, current_item, @warehouse)
                             Ecommerce::V1::Entities::Carts.represent(
                               @current_cart, warehouse: @warehouse, list: true
                             )
                           end

                success_response_with_json(I18n.t('Ecom.success.messages.line_item_remove_successful'),
                                           HTTP_CODE[:OK], response)
              rescue StandardError => error
                Rails.logger.error "\n#{__FILE__}\nUnable to remove Shopoth line Item due to: #{error.message}"
                error!(failure_response_with_json(I18n.t('Ecom.errors.messages.line_item_remove_failed'),
                                                  HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
              end
            end

            # add by one
            desc 'Add by one quantity.'
            route_setting :authentication, optional: true
            route_param :shopoth_line_item_id do
              params do
                requires :warehouse_id, type: Integer
              end
              put '/add_one' do
                shopoth_line_item = @current_cart.shopoth_line_items.find_by(id: params[:shopoth_line_item_id])
                unless shopoth_line_item.present?
                  error!(failure_response_with_json(I18n.t('Ecom.errors.messages.cart_item_not_found'),
                                                    HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
                end
                variant = shopoth_line_item.variant
                sample_qty = @current_cart.shopoth_line_items.where(
                  'sample_for IS NOT NULL AND variant_id = ?', shopoth_line_item.variant_id
                ).sum(&:quantity)
                if shopoth_line_item.sample_for.present?
                  error!(failure_response_with_json(I18n.t('Ecom.errors.messages.sample_item_error'),
                                                    HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
                end
                unless quantity_available?(shopoth_line_item.quantity + 1 + sample_qty, variant, @warehouse)
                  error!(failure_response_with_json(I18n.t('Ecom.errors.messages.unavailable_quantity'),
                                                    HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
                end

                quantity_present = variant.product.validate_products_max_limit(@current_cart.shopoth_line_items, 1)
                unless quantity_present[:success]
                  error!(failure_response_with_json(I18n.t('Ecom.errors.messages.max_limit_exceed'),
                                                    HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
                end

                item = Discounts::SkuPromotions.call(variant: variant, cart: @current_cart,
                                                     quantity: shopoth_line_item.quantity + 1,
                                                     line_item: shopoth_line_item,
                                                     warehouse_id: @warehouse.id)
                if item.result[:success] == false
                  error!(failure_response_with_json(item.result[:error], HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                         HTTP_CODE[:OK])
                end

                # @current_cart.coupon_applicable?('organic')
                @current_cart.update_cart_attr(user_domain, @warehouse, @current_user)
                response = Ecommerce::V1::Entities::Carts.represent(
                  @current_cart, warehouse: @warehouse, list: true
                )
                success_response_with_json(I18n.t('Ecom.success.messages.one_quantity_addition_successful'),
                                           HTTP_CODE[:OK], response)
              rescue StandardError => error
                Rails.logger.error "\n#{__FILE__}\nUnable to increase quantity due to: #{error.message}"
                error!(failure_response_with_json(I18n.t('Ecom.errors.messages.quantity_increase_failed'),
                                                  HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:OK])
              end
            end

            # decrease by one
            desc 'Decrease by one quantity.'
            route_setting :authentication, optional: true
            route_param :shopoth_line_item_id do
              params do
                requires :warehouse_id, type: Integer
              end
              put '/dec_one' do
                shopoth_line_item = @current_cart.shopoth_line_items.find_by(id: params[:shopoth_line_item_id])
                unless shopoth_line_item.present?
                  error!(failure_response_with_json(I18n.t('Ecom.errors.messages.cart_item_not_found'),
                                                    HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
                end
                if shopoth_line_item.sample_for.present?
                  error!(failure_response_with_json(I18n.t('Ecom.errors.messages.sample_item_error'),
                                                    HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
                end
                unless shopoth_line_item.quantity > 1
                  error!(failure_response_with_json(I18n.t('Ecom.errors.messages.at_least_one_quantity_failed'),
                                                    HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:OK])
                end

                item = Discounts::SkuPromotions.call(variant: shopoth_line_item.variant, cart: @current_cart,
                                                     quantity: shopoth_line_item.quantity - 1,
                                                     line_item: shopoth_line_item,
                                                     warehouse_id: @warehouse.id)
                if item.result[:success] == false
                  error!(failure_response_with_json(item[:error], HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                         HTTP_CODE[:OK])
                end

                @current_cart.coupon_applicable?('organic')
                @current_cart.update_cart_attr(user_domain, @warehouse, @current_user)
                response = Ecommerce::V1::Entities::Carts.represent(@current_cart, warehouse: @warehouse, list: true)
                success_response_with_json(I18n.t('Ecom.success.messages.one_quantity_decrease_successful'),
                                           HTTP_CODE[:OK], response)
              rescue StandardError => error
                Rails.logger.error "\n#{__FILE__}\nUnable to decrease quantity due to: #{error.message}"
                error!(failure_response_with_json(I18n.t('Ecom.errors.messages.quantity_decrease_failed'),
                                                  HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
              end
            end
          end

          # delete specific cart
          desc 'Delete Cart or Empty Cart.'
          route_setting :authentication, optional: true
          delete do
            @current_cart.destroy_with_shopoth_line_items
            success_response_with_json(I18n.t('Ecom.success.messages.cart_delete_successful'),
                                       HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to delete cart due to: #{error.message}"
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.cart_delete_failed'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
