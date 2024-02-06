module ShopothPartner
  module V1
    class RetailerAssistants < ShopothPartner::Base
      helpers do
        def whose_coupon(code, user)
          coupon = Coupon.where(usable_type: nil).unused.find_by(code: code)
          if coupon.nil? && user.present?
            coupon = @current_retailer.coupons.unused.find_by(code: code) if @current_retailer
            coupon ||= user.coupons.unused.find_by(code: code)
          end
          coupon
        end

        def rule_applicable?(coupon, promo_coupon, locations, user)
          rule_type = %w(Warehouse User Partner District Thana Area)
          coupon_rule = promo_coupon.promo_coupon_rules.find_by(ruleable_type: rule_type)
          case coupon_rule&.ruleable_type
          when 'User'
            unless coupon.usable == user
              error!(respond_with_json("Coupon isn't applicable for this user.",
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
          when 'Warehouse'
            unless locations[:warehouse]
              error!(respond_with_json('You need to select warehouse before using this coupon.',
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])

            end

            unless coupon.usable == locations[:warehouse]
              error!(respond_with_json("Coupon isn't applicable for this warehouse.",
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
          when 'Partner'
            unless locations[:partner]
              error!(respond_with_json('You need to select partner before using this coupon.',
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end

            unless coupon.usable == locations[:partner]
              error!(respond_with_json("Coupon isn't applicable for this partner.",
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
          when 'District'
            unless locations[:district]
              error!(respond_with_json('You need to select district before using this coupon.',
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end

            unless coupon.usable == locations[:district]
              error!(respond_with_json("Coupon isn't applicable for this district.",
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
          when 'Thana'
            unless locations[:thana]
              error!(respond_with_json('You need to select thana before using this coupon.',
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end

            unless coupon.usable == locations[:thana]
              error!(respond_with_json("Coupon isn't applicable for this thana.",
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
          when 'Area'
            unless locations[:area]
              error!(respond_with_json('You need to select area before using this coupon.',
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end

            unless coupon.usable == locations[:area]
              error!(respond_with_json("Coupon isn't applicable for this area.",
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end
        end

        def current_partner_cart
          check_b2b? ? @current_partner.carts.b2b.last : @current_partner.carts.b2c.last
        end
      end

      resource :retailer_assistants do
        desc 'Fetch ra promotion'
        route_setting :authentication, type: RetailerAssistant
        get '/promotions' do
          promotions = Promotion.active.unexpired.ra_discount.where(warehouse_id: @current_retailer.warehouse.id).
                       joins(:coupons).where(coupons: { usable_type: 'RetailerAssistant',
                                                        usable_id: @current_retailer.id, })
          promotions = promotions.uniq
          ShopothPartner::V1::Entities::Promotions.represent(promotions, retailer_assistant: @current_retailer)
        rescue StandardError => error
          error!(respond_with_json("Unable to fetch. Due to error: #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Apply coupon code.'
        params do
          requires :coupon_code, type: String
          requires :phone, type: String
        end
        route_setting :authentication, type: 'Both'
        put 'apply/coupon' do
          user = check_b2b? ? @current_partner : User.find_by(phone: params[:phone])
          unless user
            error!(respond_with_json(I18n.t('Partner.errors.messages.customer_not_found'),
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end

          coupon = Coupon.unused.find_by(code: params[:coupon_code])
          unless coupon
            error!(respond_with_json(I18n.t('Partner.errors.messages.invalid_coupon'),
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if (coupon.promotion? || coupon.return_voucher? || coupon.acquisition?) &&
             user.customer_orders.find_by(coupon_code: coupon.code).present?
            error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if (coupon.acquisition? || coupon.return_voucher?) && coupon.usable != user
            error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
          cart = current_partner_cart
          unless cart
            error!(respond_with_json(I18n.t('Ecom.errors.messages.min_cart_error'),
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if (coupon.first_registration? || coupon.acquisition?) &&
             !coupon.valid_for_first_time?(user)
            error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if coupon.multi_user? && !coupon.valid_for_multi_user?(user)
            error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])

          end
          unless coupon.check_phone_numbers(user)
            error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if coupon.skus.present? && coupon.coupon_category.present? &&
             (coupon.valid_for_category(cart) == false || coupon.check_sku(cart) == false)
            error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if coupon.skus.present? && coupon.coupon_category.present? &&
             coupon.valid_for_category(cart) == false
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if (coupon.skus.present? || coupon.coupon_category.present?) &&
             coupon.valid_for_category(cart) == false && coupon.check_sku(cart) == false
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.coupon_use_error'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
          warehouse = @current_partner.route.warehouse
          if coupon.promo_coupon.present?
            promo_coupon = coupon.promo_coupon
            unless promo_coupon&.running?
              error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_not_running'),
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end

            locations = { warehouse: warehouse, partner: @current_partner, area: @current_partner.address&.area,
                          district: @current_partner.address&.district, thana: @current_partner.address&.thana, }
            rule_applicable?(coupon, promo_coupon, locations, user)

            applicable = promo_coupon.applicable?(cart, user, 'induced', locations)
            unless applicable
              error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_not_applicable'),
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end

            if cart.coupon_code == coupon.code
              error!(respond_with_json(I18n.t('Ecom.errors.messages.coupon_already_applied'),
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
            promo_coupon.apply_discount(cart, coupon, user)
          else
            discount_context = Discounts::DiscountCalculation.call(cart: cart,
                                                                   member: member_partner,
                                                                   coupon: coupon,
                                                                   warehouse: warehouse,
                                                                   user: user)
            max_discount = discount_context.max_discount
            total_discount = discount_context.total_discount
            if max_discount[:type] == 'promo' && max_discount[:applicable] == false
              error!(respond_with_json(I18n.t('Partner.errors.messages.expired_coupon'),
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
            if discount_context.cart[:sub_total] - discount_context.max_discount[:discount] < 180
              error!(respond_with_json(I18n.t('Ecom.errors.messages.min_cart_error'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end

            cart_user = check_b2b? ? { partner_id: user.id } : { user_id: user.id }
            cart_updated_attrs = { cart_discount: total_discount[:discount],
                                   coupon_code: total_discount[:coupon_code],
                                   cart_dis_type: total_discount[:dis_type], }.merge(cart_user)

            cart.update!(cart_updated_attrs)
            cart.cart_promotions_create_update(total_discount[:promotion])
          end
          present cart, with: ShopothPartner::V1::Entities::CartDetails
        rescue StandardError => error
          Rails.logger "app_coupon_apply_failed: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.invalid_coupon'), HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Forget password'
        params do
          requires :phone, type: String
        end
        route_setting :authentication, optional: true
        put :secret do
          ra = RetailerAssistant.find_by_phone(params[:phone])
          if ra.present?
            otp ||= rand(10_000..99_999)
            ra.update!(otp: otp)
            message = "Your One Time Password(OTP) for  Shopoth is #{ra.otp}"
            sms_context = SmsManagement::SendMessage.call(phone: ra.phone, message: message)
            if SmsLog.otp.exit_sms_limit?(ra.phone)
              error!(failure_response_with_json(I18n.t('Ecom.errors.messages.too_many_otp_requests'),
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
            SmsLogJob.perform_later(SmsLog.sms_types[:otp],
                                    sms_context.phone,
                                    sms_context.message,
                                    sms_context.gateway_response)
            if sms_context.success?
              status :ok
              { success: true, status_code: HTTP_CODE[:OK], message: 'Successfully otp sent' }
            else
              status :unprocessable_entity
              { success: false, status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: sms_context.error }
            end
          else
            status :not_found
            { success: false, message: 'RA does not exist with this phone number', status_code: HTTP_CODE[:NOT_FOUND] }
          end
        rescue StandardError => error
          Rails.logger.info error.to_s
          error!("Unable to send otp, reason: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Password reset'
        params do
          requires :phone, type: String
          requires :otp, type: String
          requires :password, type: String
          requires :password_confirmation, type: String
        end
        route_setting :authentication, optional: true
        put :reset_password do
          ra = RetailerAssistant.find_by(phone: params[:phone], otp: params[:otp])
          if ra.present?
            ra.update!(password: params[:password], password_confirmation: params[:password])
            status :ok
            { success: true, message: 'Successfully reset', status_code: HTTP_CODE[:OK] }
          else
            status :not_found
            { success: false, message: 'Wrong number or otp provided', status_code: HTTP_CODE[:NOT_FOUND] }
          end
        rescue StandardError => error
          Rails.logger.info error.to_s
          error!(respond_with_json("Unable to update, reason: #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
