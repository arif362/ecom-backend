# frozen_string_literal: true

module Ecommerce
  module V1
    class PromoCoupons < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::ProductSerializer
      resources :promo_coupons do
        # TODO: Need to remove this API after deploying promotion coupon apply on production.
        desc 'Apply promo coupons.'
        params do
          requires :coupon_code, type: Integer
          requires :cart_id, type: Integer
          requires :order_type, type: String
          requires :warehouse_id, type: Integer
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
          coupon = Coupon.find_by(code: params[:coupon_code])
          unless coupon
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_not_found'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          promo_coupon = coupon.promo_coupon
          unless promo_coupon&.running?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          cart = Cart.find_by(id: params[:cart_id])
          unless cart
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.cart_not_found'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          coupon_rule = promo_coupon.promo_coupon_rules.find_by(ruleable_type: %w(Warehouse User Partner District Thana Area))
          case coupon_rule.ruleable_type
          when 'Warehouse'
            unless warehouse
              error!(failure_response_with_json('You need to select warehouse before using this coupon.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])

            end
          when 'Partner'
            unless partner
              error!(failure_response_with_json('You need to select partner before using this coupon.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
          when 'District'
            unless district
              error!(failure_response_with_json('You need to select district before using this coupon.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
          when 'Thana'
            unless thana
              error!(failure_response_with_json('You need to select thana before using this coupon.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
          when 'Area'
            unless area
              error!(failure_response_with_json('You need to select area before using this coupon.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
          end

          # co = CustomerOrder.find_by(coupon_code: coupon.code)
          # if co.present?
          #   Rails.logger.info "Coupon already applied in customer order: #{co.id}"
          #   error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
          #                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          # end
          locations = { warehouse: warehouse, partner: partner, district: district, thana: thana, area: area }
          applicable = promo_coupon.applicable?(cart, @current_user, params[:order_type], locations)
          unless applicable
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_not_applicable'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          promo_coupon.apply_discount(cart, coupon, @current_user)
          response = Ecommerce::V1::Entities::Carts.represent(cart, warehouse: warehouse, list: true)
          success_response_with_json(I18n.t('Ecom.success.messages.coupon_apply'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n\nUnable to apply promo coupons due to: #{error.message}"
          error!(failure_response_with_json('Unable to apply promo coupons.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
