module ShopothPartner
  module V1
    class Customers < ShopothPartner::Base
      helpers do
        # def add_line_items_to_cart(variants, user)
        #   cart = Cart.create
        #   cart.user = user
        #   commission = 0.0
        #   variants.each do |val|
        #     variant = Variant.find(val[:variant_id])
        #     cart.add_cart(variant, val[:quantity])
        #
        #     retailer_price = variant.price_retailer || 0
        #     consumer_price = variant.price_consumer || 0
        #     commission += (consumer_price - retailer_price) * val[:quantity]
        #   rescue => error
        #     error! respond_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        #   end
        #   cart.update!(cart.cart_attributes)
        #
        #   [cart, commission]
        # end

        def validate_user_partner(user)
          wh_district = member_partner
          if wh_district.present? && user.shopoth?
            error!(respond_with_json('Only member user can place the order in Dhaka',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        def current_partner_cart
          check_b2b? ? @current_partner.carts.b2b.last : @current_partner.carts.b2c.last
        end
      end

      resource :customer do
        desc 'Verify token.'
        params do
          requires :phone, type: String
          requires :otp, type: Integer
          requires :token, type: String
        end
        route_setting :authentication, type: 'Both'
        post '/verify_token' do
          user = User.find_by(phone: params[:phone], otp: params[:otp])
          if user.present?
            user.update!(is_otp_verified: true, verifiable: @current_retailer.present? ? @current_retailer : @current_partner, verified_at: Time.now)
            status :ok
            {
              message: I18n.t('Partner.success.messages.otp_verified'),
              customer_id: user.id,
            }
          else
            status :not_acceptable
            error!(respond_with_json(I18n.t('Partner.errors.messages.otp_verification_failed'),
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to verify otp due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.otp_verification_failed'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Customer details.'
        route_param :id do
          get 'details' do
            cus_id = params[:id]
            customer = User.find(cus_id)

            status :ok
            {
              name: customer&.name,
              phone: customer.phone,
              email: customer.email,
            }
          rescue StandardError => error
            Rails.logger.error "#{__FILE__} \nUnable to find customer with id #{cus_id} due to: #{error.message}"
            error!(respond_with_json(I18n.t('Partner.errors.messages.customer_find_failed'),
                                     HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end
        end

        desc 'Customer Confirmation.'
        params do
          requires :first_name, type: String
          requires :last_name, type: String
          requires :phone, type: String
          optional :email, type: String
          optional :gender, type: String
          optional :age, type: String
        end
        route_setting :authentication, type: 'Both'
        post 'confirm' do
          user = User.find_by(phone: params[:phone])
          if current_partner_cart&.coupon_code.present?
            current_partner_cart&.update!(coupon_code: nil, promotion_id: nil, cart_discount: 0.0)
          end

          if user.present?
            validate_user_partner(user)
            user_attributes = {}
            unless user.is_otp_verified
              password = (0...8).map { (65 + rand(26)).chr }.join
              message = "Your Shopoth UserID is #{params[:phone]}, Password: #{password}"
              send_message = SmsManagement::SendMessage.call(phone: params[:phone], message: message)
              if send_message.success?
                user_attributes[:password] = password
                user_attributes[:password_confirmation] = password
              else
                status :unprocessable_entity
                error!(respond_with_json(I18n.t('Partner.errors.messages.customer_verify_failed'),
                                         HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
            end
            otp = SmsManagement::SendOtp.call(phone: params[:phone])
            if otp.success?
              user_attributes[:otp] = otp.otp
              user.update_attributes!(user_attributes)
              status :ok
              { success: true, token: otp.token, message: I18n.t('Partner.success.messages.existing_customer_otp_sent') }
            else
              status :unprocessable_entity
              error!(respond_with_json(I18n.t('Partner.errors.messages.customer_verify_failed'),
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          elsif member_partner.present? && user.nil?
            error!(respond_with_json('Only member user can place the order in Dhaka', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          else
            password = (0...8).map { (65 + rand(26)).chr }.join
            registerable = @current_retailer.present? ? @current_retailer : @current_partner
            params[:full_name] = [params[:first_name].strip, params[:last_name].strip].join(' ')
            params.merge!(password: password, password_confirmation: password, registerable: registerable)
            params[:email] = nil if params[:email] == ''
            user_created = User.create!(params)
            message = "Your Shopoth UserID is #{params[:phone]}, Password: #{password}"
            send_message = SmsManagement::SendMessage.call(phone: params[:phone], message: message)
            otp = SmsManagement::SendOtp.call(phone: params[:phone])

            if user_created && send_message.success? && otp.success?
              status :created
              customer = User.find_by(phone: params[:phone])
              customer.update!(otp: otp.otp)
              { success: true, token: otp.token, customer_id: customer, message: I18n.t('Partner.success.messages.new_customer_otp_sent') }
            else
              status :unprocessable_entity
              error!(respond_with_json(I18n.t('Partner.errors.messages.customer_verify_failed'),
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to verify customer due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.customer_verify_failed'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        # desc 'Place Order.'
        # params do
        #   requires :phone, type: String
        #   requires :otp, type: Integer
        #   requires :token, type: String
        #   requires :first_name, type: String
        #   requires :last_name, type: String
        #   requires :variants, type: Array do
        #     requires :variant_id, type: Integer
        #     optional :quantity, type: Integer
        #   end
        # end
        #
        # post '/place_order' do
        #   user = User.find_by!(phone: params[:phone])
        #   otp = SmsManagement::VerifyOtp.call(phone: params[:phone], otp: params[:otp], token: params[:token])
        #
        #   if otp.success?
        #     warehouse = @current_partner.route.warehouse
        #     params[:variants].each do |val|
        #       warehouse_variant = WarehouseVariant.find_by(warehouse: warehouse, variant_id: val[:variant_id])
        #       if val[:quantity] <= 0
        #         status :not_acceptable
        #         return { success: false, message: I18n.t('Partner.errors.messages.zero_quantity_for_order_place') }
        #       elsif (warehouse_variant&.available_quantity || 0) < val[:quantity]
        #         status :not_acceptable
        #         return { success: false, message: I18n.t('Partner.errors.messages.unavailable_quantity_for_order_place') }
        #       end
        #     end
        #
        #     user.update_attribute(:is_otp_verified, true)
        #
        #     cart, commission = add_line_items_to_cart(params[:variants], user)
        #     product_visibility = cart.products_visible?
        #     unless product_visibility.all?(true)
        #       error!(respond_with_json(I18n.t('Ecom.errors.messages.product_visibility'),
        #                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        #     end
        #
        #     less_than_max_quantity = cart.check_products_max_limit
        #     unless less_than_max_quantity.all?(true)
        #       error!(respond_with_json(I18n.t('Ecom.errors.messages.max_limit_exceed'),
        #                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        #     end
        #
        #     order_context = OrderManagement::CreateCustomerOrder.call(
        #       customer: user,
        #       cart: cart,
        #       partner: @current_partner,
        #       address: @current_partner&.address,
        #       billing_address_id: @current_partner&.address&.id,
        #       shipping_address_id: @current_partner&.address&.id,
        #       shipping_type: 'pick_up_point',
        #       new_address: { full_name: "#{params[:first_name]} #{params[:last_name]}", phone: params[:phone] },
        #       form_of_payment: :cash_on_delivery,
        #       order_type: 'induced',
        #       commission: commission,
        #       customer_orderable: @current_partner,
        #     )
        #
        #     if order_context.success?
        #       SendSmsJob.perform_later(order_context.order)
        #       CreateNotification.call(
        #         user: order_context.order.customer,
        #         message: Notification.get_notification_message(order_context.order),
        #         order: order_context.order,
        #       )
        #
        #       app_notification = AppNotification.order_placed_notification(order_context&.order)
        #       attributes = @locale == :bn ? get_hash(app_notification[:bn_title], app_notification[:bn_message]) : get_hash(app_notification[:title], app_notification[:message])
        #       PushNotification::CreateAppNotificationsPartner.call(
        #         app_user: @current_partner,
        #         title: app_notification[:title],
        #         bn_title: app_notification[:bn_title],
        #         message: app_notification[:message],
        #         bn_message: app_notification[:bn_message],
        #         attributes: attributes,
        #       )
        #
        #       message = "Your Order (ID: #{order_context&.order&.id}) has been Placed. You have to pay #{order_context&.order&.total_price}TK to the partner after receiving the product."
        #       send_message = SmsManagement::SendMessage.call(phone: params[:phone], message: message)
        #       cart.destroy
        #
        #       if send_message.success?
        #         present order_context.order, with: ShopothPartner::V1::Entities::CustomerOrders
        #       else
        #         status :unprocessable_entity
        #         error!(send_message.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        #       end
        #     else
        #       error!(order_context.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        #     end
        #   else
        #     error!(otp.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        #   end
        # end

        desc 'resend otp'
        params do
          requires :phone, type: String, allow_blank: false
        end

        post 'resend_otp' do
          phone = params[:phone]
          otp = SmsManagement::SendOtp.call(phone: phone)
          if SmsLog.otp.exit_sms_limit?(params[:phone])
            status :unprocessable_entity
            error! respond_with_json(I18n.t('Ecom.errors.messages.too_many_otp_requests'), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          if otp.success?
            status :ok
            customer_id = User.find_by(phone: params[:phone])
            customer_id.update!(otp: otp.otp)
            { success: true, token: otp.token, customer_id: customer_id, message: 'otp sent' }
          else
            status :unprocessable_entity
            error! respond_with_json("OTP error: #{otp.error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'User registration by RA.'
        params do
          requires :first_name, type: String
          requires :last_name, type: String
          requires :phone, type: String
          optional :email, type: String
          requires :partner_id, type: String
          optional :is_app_download, type: Boolean
          optional :has_smart_phone, type: Boolean
          requires :gender, type: String
          requires :age, type: String
        end
        route_setting :authentication, type: RetailerAssistant
        post :register do
          partner = Partner.find_by(id: params[:partner_id].to_i)
          fail StandardError, 'Partner not found, please provide valid partner' unless partner

          password = (0...8).map { (65 + rand(26)).chr }.join
          params[:age] = params[:age].to_i
          user_params = params.merge(full_name: "#{params[:first_name].strip} #{params[:last_name].strip}", password: password, password_confirmation: password)
          user = User.find_by(phone: params[:phone])

          if user.blank?
            user = @current_retailer.users.create!(user_params)
          elsif user.is_otp_verified
            fail StandardError, 'User already exist'
          else
            user.update!(user_params)
          end

          otp = SmsManagement::SendOtp.call(phone: params[:pphone])
          user.update!(otp: otp.otp)
          message = "Your Shopoth UserID is #{params[:phone]}, Password: #{password}. Please activate your account by verifying with OTP: #{user.otp}."
          SmsManagement::SendMessage.call(phone: params[:phone], message: message)
          status :created
          { success: true, message: 'successfully created', status_code: HTTP_CODE[:CREATED] }
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nCustomer registration failed due to: #{error.message}"
          status :unprocessable_entity
          { success: false, message: error.to_s, status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY] }
        end

        desc 'Resend otp after ra user reg'
        params do
          requires :phone, type: String
        end
        route_setting :authentication, type: RetailerAssistant
        put :otp_resend do
          params[:phone]
          user = User.find_by(phone: params[:phone])
          if user.present?
            otp = rand(10_000..99_999)
            user.update!(otp: otp)
            message = "Your One Time Password(OTP) for  Shopoth is #{user.otp}"
            sms_context = SmsManagement::SendMessage.call(phone: user.phone, message: message)
            if sms_context.success?
              status :ok
              { success: true, status_code: HTTP_CODE[:OK], message: 'Successfully otp sent' }
            else
              status :unprocessable_entity
              { success: false, status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: sms_context.error }
            end
          else
            status :not_found
            { success: false, message: 'User does not exist', status_code: HTTP_CODE[:NOT_FOUND] }
          end
        rescue StandardError => error
          status :unprocessable_entity
          { success: false, message: error.to_s, status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY] }
        end

        desc 'Verify otp by ra user reg'
        params do
          requires :phone, type: String
          requires :otp, type: String
        end
        route_setting :authentication, type: RetailerAssistant
        put '/verify_otp' do
          user = User.find_by(phone: params[:phone], otp: params[:otp])
          if user.present?
            user.update!(is_otp_verified: true, verifiable: @current_retailer, verified_at: Time.now)
            status :ok
            { success: true, status_code: HTTP_CODE[:OK], message: 'User successfully verified!' }
          else
            status :not_found
            { success: false, message: 'OTP does not match', status_code: HTTP_CODE[:NOT_FOUND] }
          end
        rescue StandardError => error
          status :unprocessable_entity
          { success: false, message: error.to_s, status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY] }
        end
      end
    end
  end
end
