# frozen_string_literal: true

module ShopothPartner
  module V1
    class Carts < ShopothPartner::Base
      helpers ShopothPartner::V1::Serializers::CartShowSerializer

      helpers do
        def quantity_available?(quantity, variant, warehouse)
          available_quantity = WarehouseVariant.find_by(variant_id: variant.id, warehouse_id: warehouse.id).available_quantity
          available_quantity >= quantity
        end

        def current_quantity
          line_item = @current_cart.shopoth_line_items.find_by(variant_id: @variant.id)
          line_item ? line_item.quantity + params[:quantity] : params[:quantity]
        end

        def error_message!
          error!(respond_with_json(I18n.t('Partner.errors.messages.product_quantity_not_available'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        def current_partner_cart
          check_b2b? ? @current_partner.carts.b2b.last : @current_partner.carts.b2c.last
        end
      end

      resource :carts do
        desc 'Count items of a cart.'
        get 'items' do
          cart = current_partner_cart
          status :ok
          return { items: 0 } unless cart.present?

          {
            items: cart.shopoth_line_items.count,
          }
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to count line items due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.line_items_count_failed'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        # Get all shopoth line items in cart
        desc 'Get all shopoth_line_item in cart.'
        get 'details' do
          cart = Cart.includes(shopoth_line_items: { variant: [product: :brand] }).find_by(id: current_partner_cart&.id)
          error! respond_with_json(I18n.t('Partner.errors.messages.cart_not_found'), HTTP_CODE[:NOT_FOUND]) unless
            cart.present?
          warehouse = @current_partner.route.warehouse
          cart.validate_cart_items_price(warehouse, @business_type)
          cart.update_cart_attr(member_partner, warehouse, nil)
          if @locale == :bn
            ShopothPartner::V1::Entities::BnCartDetails.represent(cart, warehouse: warehouse)
          else
            ShopothPartner::V1::Entities::CartDetails.represent(cart, warehouse: warehouse)
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to show cart details due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.cart_details_fetch_failed'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # create a cart and populate with shopoth_line_items
        desc 'Create a cart.'
        params do
          requires :variant_id, type: Integer
          requires :quantity, type: Integer, values: ->(v) { v.positive? }
        end
        post do
          warehouse = @current_partner.route.warehouse
          variant = warehouse.variants.find(params[:variant_id])
          quantity = params[:quantity]
          current_cart = current_partner_cart || Cart.create!(partner: @current_partner, business_type: @business_type)
          existing_quantity = current_cart.shopoth_line_items.find_by(variant: variant)&.quantity.to_i
          unless quantity_available?(quantity + existing_quantity, variant, warehouse)
            error!(respond_with_json(I18n.t('Partner.errors.messages.product_quantity_not_available'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          quantity_present = variant.product.validate_products_max_limit(current_cart.shopoth_line_items, quantity)
          unless quantity_present[:success]
            error!(respond_with_json(I18n.t('Ecom.errors.messages.max_limit_exceed'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          item = current_cart.add_cart(variant, quantity, warehouse.id, check_b2b? ? 'b2b' : 'b2c')
          if item[:success] == false
            error!(respond_with_json(I18n.t('Partner.errors.messages.cart_creation_failed'),
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          current_cart.update_cart_attr(member_partner, warehouse, nil)
          present item[:line_item], with: ShopothPartner::V1::Entities::CartCreation
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to create cart due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.cart_creation_failed'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # Update cart
        # API is not used at all
        desc 'Update Cart'
        route_param :id do
          put do
            current_cart = Cart.find(params[:id])
            # TODO: Users old cart will be merged in future, for now it is deleted
            if current_partner_cart
              cart = current_partner_cart
              cart.destroy_with_shopoth_line_items unless cart.id == current_cart.id
            end
            current_cart.partner_id = @current_partner.id
            current_cart.update!(current_cart.cart_attributes(member_partner))
            present current_cart, with: ShopothPartner::V1::Entities::CartDetails
          rescue StandardError => error
            error!("Cannot update due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        resource :shopoth_line_items do
          params do
            requires :variant_id, type: Integer
            requires :quantity, type: Integer, values: ->(v) { v.positive? }
            requires :warehouse_id, type: Integer
          end
          # API is not used at all
          put do
            warehouse = Warehouse.find(params[:warehouse_id])
            @current_cart = Cart.find(params[:id])
            @variant = warehouse.variants.find(params[:variant_id])
            error_message! unless quantity_available?(current_quantity, @variant, warehouse)
            shopoth_line_item = @current_cart.add_cart(@variant, params[:quantity])
            @current_cart.update_cart_attr(member_partner, warehouse, nil)
            present shopoth_line_item, with: ShopothPartner::V1::Entities::CartCreation
          rescue StandardError => error
            error!("Cannot update due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Remove from a cart.'
          route_param :shopoth_line_item_id do
            delete do
              current_cart = current_partner_cart
              current_item = ShopothLineItem.find(params[:shopoth_line_item_id])
              if !!current_item && !!current_cart
                if current_item.sample_for.present?
                  error!(respond_with_json(I18n.t('Ecom.errors.messages.sample_item_error'),
                                           HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
                end

                if current_item.customer_order.present? && current_item.cart.present?
                  current_item.samples.update_all(cart_id: nil) if current_item.samples.present?
                  current_item.update!(cart_id: nil)
                else
                  current_item.destroy
                  current_cart.coupon_applicable?('induced')
                end
                current_cart.update_cart_attr(member_partner, @current_partner.route.warehouse, nil)
                status :ok
                present current_cart, with: ShopothPartner::V1::Entities::CartInfo
              end
            rescue StandardError => error
              Rails.logger.error "#{__FILE__} \nUnable to remove product due to: #{error.message}"
              error!(respond_with_json(I18n.t('Partner.errors.messages.line_item_delete_failed'),
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end

          desc 'Add by one quantity.'
          route_param :shopoth_line_item_id do
            put '/add-one' do
              warehouse = @current_partner.route.warehouse
              current_cart = current_partner_cart
              shopoth_line_item = ShopothLineItem.find(params[:shopoth_line_item_id])
              if shopoth_line_item.sample_for.present?
                error!(respond_with_json(I18n.t('Ecom.errors.messages.sample_item_error'),
                                         HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end

              sample_qty = current_cart.shopoth_line_items.where('sample_for IS NOT NULL AND variant_id = ?',
                                                                 shopoth_line_item.variant_id).
                           sum(&:quantity)
              if quantity_available?(shopoth_line_item.quantity + 1 + sample_qty, shopoth_line_item.variant, warehouse)
                quantity_present = shopoth_line_item.variant.product.validate_products_max_limit(current_cart.shopoth_line_items, 1)
                unless quantity_present[:success]
                  error!(respond_with_json(I18n.t('Ecom.errors.messages.max_limit_exceed'),
                                           HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
                end

                item = Discounts::SkuPromotions.call(variant: shopoth_line_item.variant, cart: current_cart,
                                                     quantity: shopoth_line_item.quantity + 1,
                                                     line_item: shopoth_line_item,
                                                     warehouse_id: warehouse.id,
                                                     business_type: @business_type)
                if item.result[:success] == false
                  Rails.logger.error "#{__FILE__} \nUnable to increase quantity due to: #{item.result[:error]}"
                  error!(respond_with_json(I18n.t('Partner.errors.messages.unavailable_quantity_for_order_place'),
                                           HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
                end

                # current_cart.coupon_applicable?('induced')
                current_cart.update_cart_attr(member_partner, warehouse, nil)
                present shopoth_line_item, with: ShopothPartner::V1::Entities::CartCreation
              else
                error!(respond_with_json(I18n.t('Partner.errors.messages.unavailable_quantity_for_order_place'),
                                         HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
            rescue StandardError => error
              Rails.logger.error "#{__FILE__} \nUnable to increase quantity due to: #{error.message}"
              error!(respond_with_json(I18n.t('Partner.errors.messages.quantity_addition_failed'),
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end

          desc 'Decrease by one quantity.'
          route_param :shopoth_line_item_id do
            put '/dec-one' do
              current_cart = current_partner_cart
              warehouse = @current_partner.route.warehouse
              shopoth_line_item = ShopothLineItem.find(params[:shopoth_line_item_id])
              if shopoth_line_item.sample_for.present?
                error!(respond_with_json(I18n.t('Ecom.errors.messages.sample_item_error'),
                                         HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end

              if shopoth_line_item.quantity > 1 && current_cart
                item = Discounts::SkuPromotions.call(variant: shopoth_line_item.variant, cart: current_cart,
                                                     quantity: shopoth_line_item.quantity - 1,
                                                     line_item: shopoth_line_item,
                                                     warehouse_id: warehouse.id,
                                                     business_type: @business_type)
                if item.result[:success] == false
                  error!(respond_with_json(I18n.t('Partner.errors.messages.quantity_decrease_failed'),
                                           HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
                end

                current_cart.coupon_applicable?('induced')
                current_cart.update_cart_attr(member_partner, warehouse, nil)
                present shopoth_line_item, with: ShopothPartner::V1::Entities::CartCreation
              else
                respond_with_json('Must keep one product', HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
            rescue StandardError => error
              Rails.logger.error "#{__FILE__} \nUnable to decrease quantity due to: #{error.message}"
              error!(respond_with_json(I18n.t('Partner.errors.messages.quantity_decrease_failed'),
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        end

        desc 'Delete Cart/Empty Cart.'
        delete 'delete' do
          cart = current_partner_cart
          if cart
            cart.shopoth_line_items.each do |item|
              item.customer_order.present? ? item.update!(cart_id: nil) : item.destroy
            end
            cart.destroy
            respond_with_json(I18n.t('Partner.success.messages.deletion_successful'), HTTP_CODE[:OK])
          else
            respond_with_json(I18n.t('Partner.errors.messages.cart_not_found'), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to delete cart due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.cart_deletion_failed'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
