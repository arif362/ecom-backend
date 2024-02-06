# frozen_string_literal: true

module Ecommerce
  module V1
    class Coupons < Ecommerce::Base
      helpers do
        def rule_applicable?(coupon, promo_coupon, locations, user)
          rule_type = %w(Warehouse User Partner District Thana Area)
          coupon_rule = promo_coupon.promo_coupon_rules.find_by(ruleable_type: rule_type)
          case coupon_rule&.ruleable_type
          when 'User'
            unless coupon.usable == user
              error!(failure_response_with_json("Coupon isn't applicable for this user.",
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
          when 'Warehouse'
            unless locations[:warehouse]
              error!(failure_response_with_json('You need to select warehouse before using this coupon.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])

            end

            unless coupon.usable == locations[:warehouse]
              error!(failure_response_with_json("Coupon isn't applicable for this warehouse.",
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
          when 'Partner'
            unless locations[:partner]
              error!(failure_response_with_json('You need to select partner before using this coupon.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            unless coupon.usable == locations[:partner]
              error!(failure_response_with_json("Coupon isn't applicable for this partner.",
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
          when 'District'
            unless locations[:district]
              error!(failure_response_with_json('You need to select district before using this coupon.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            unless coupon.usable == locations[:district]
              error!(failure_response_with_json("Coupon isn't applicable for this district.",
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
          when 'Thana'
            unless locations[:thana]
              error!(failure_response_with_json('You need to select thana before using this coupon.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            unless coupon.usable == locations[:thana]
              error!(failure_response_with_json("Coupon isn't applicable for this thana.",
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
          when 'Area'
            unless locations[:area]
              error!(failure_response_with_json('You need to select area before using this coupon.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            unless coupon.usable == locations[:area]
              error!(failure_response_with_json("Coupon isn't applicable for this area.",
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
          end
        end
      end
      namespace :coupon do
        desc 'Apply coupon.'
        params do
          requires :coupon_code, type: String
          requires :cart_id, type: Integer
          requires :warehouse_id, type: Integer
          optional :order_type, type: String
          optional :partner_id, type: Integer
          optional :district_id, type: Integer
          optional :thana_id, type: Integer
          optional :area_id, type: Integer
        end
        put :apply do
          warehouse = Warehouse.find_by(id: params[:warehouse_id])
          unless warehouse
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.warehouse_not_found'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          partner = (Partner.find_by(id: params[:partner_id]) if params[:partner_id].present?)
          district = (District.find_by(id: params[:district_id]) if params[:district_id].present?)
          thana = (Thana.find_by(id: params[:thana_id]) if params[:thana_id].present?)
          area = (Area.find_by(id: params[:area_id]) if params[:area_id].present?)

          if user_domain.present?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.member_user_coupon_apply'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          coupon = Coupon.unused.find_by(code: params[:coupon_code])
          unless coupon
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          if (coupon.promotion? || coupon.return_voucher? || coupon.acquisition?) &&
             @current_user.customer_orders.find_by(coupon_code: coupon.code).present?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          cart = Cart.find_by(id: params[:cart_id])
          unless cart
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.cart_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          # frozen_string_literal: true
          if (coupon.first_registration? || coupon.acquisition?) &&
             !coupon.valid_for_first_time?(@current_user)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          if coupon.multi_user? && !coupon.valid_for_multi_user?(@current_user)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          if (coupon.acquisition? || coupon.return_voucher?) && coupon.usable != @current_user
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          unless coupon.check_phone_numbers(@current_user)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          if coupon.skus.present? && coupon.coupon_category.present? &&
             coupon.valid_for_category(cart) == false
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          if (coupon.skus.present? || coupon.coupon_category.present?) &&
             coupon.valid_for_category(cart) == false && coupon.check_sku(cart) == false
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          if coupon.promo_coupon.present?
            promo_coupon = coupon.promo_coupon
            unless promo_coupon&.running?
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_not_running'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            locations = { warehouse: warehouse, partner: partner, district: district, thana: thana, area: area }
            rule_applicable?(coupon, promo_coupon, locations, @current_user)

            applicable = promo_coupon.applicable?(cart, @current_user, 'organic', locations)
            unless applicable
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_not_applicable'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            if cart.coupon_code == coupon.code
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_already_applied'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            promo_coupon.apply_discount(cart, coupon, @current_user)
          else
            discount_context = Discounts::DiscountCalculation.call(cart: cart,
                                                                   member: user_domain,
                                                                   coupon: coupon,
                                                                   warehouse: warehouse,
                                                                   user: @current_user)
            max_discount = discount_context.max_discount
            total_discount = discount_context.total_discount
            if max_discount[:type] == 'promo' && max_discount[:applicable] == false
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_exp_min_cart_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            if discount_context.cart[:sub_total] - discount_context.max_discount[:discount] < 180
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.min_cart_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            cart.update!(cart_discount: total_discount[:discount],
                         coupon_code: total_discount[:coupon_code],
                         cart_dis_type: total_discount[:dis_type],
                         user: @current_user)
            cart.cart_promotions_create_update(total_discount[:promotion])
          end

          response = Ecommerce::V1::Entities::Carts.represent(cart, warehouse: warehouse, list: true)
          success_response_with_json(I18n.t('Ecom.success.messages.coupon_apply'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.info "coupon_apply failed: #{__FILE__}#{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_apply_error'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Remove coupon.'
        params do
          requires :coupon_code, type: String
          requires :cart_id, type: Integer
          optional :warehouse_id, type: Integer
        end
        put 'remove' do
          cart = Cart.includes(shopoth_line_items: [variant: :product]).find(params[:cart_id])
          coupon = Coupon.find_by(code: params[:coupon_code])
          unless cart.coupon_code == coupon.code
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_remove_error'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end
          warehouse = Warehouse.find_by(id: params[:warehouse_id])
          discount_context = Discounts::DiscountCalculation.call(cart: cart,
                                                                 member_discount: user_domain,
                                                                 coupon: nil,
                                                                 warehouse: warehouse,
                                                                 user: @current_user)
          total_discount = discount_context.total_discount
          cart.update!(cart_discount: total_discount[:discount],
                       coupon_code: nil,
                       cart_dis_type: total_discount[:dis_type],
                       user: @current_user)
          cart.cart_promotions_create_update(total_discount[:promotion])
          success_response_with_json(I18n.t('Ecom.success.messages.coupon_remove_success'),
                                     HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::Carts.represent(cart,
                                                                              warehouse: warehouse,
                                                                              list: true))
        rescue StandardError => error
          Rails.logger.info "coupon_remove failed: #{__FILE__}#{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_remove_error'),
                                            HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end
      end
    end
  end
end
