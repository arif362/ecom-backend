# frozen_string_literal: true

module Ecommerce
  module V1
    class Users < Ecommerce::Base
      helpers Ecommerce::V1::Serializers::CurrentUserDetailsSerializer
      helpers do
        def subscribe_to_newsletter(email)
          news_letter = NewsLetter.find_by_email(email)
          if news_letter.present?
            news_letter.update!(is_active: true)
          else
            NewsLetter.create!(email: email)
          end
        end

        def user
          @user ||= User.find_by_email_or_phone(params[:email_or_phone])
        end

        def domain
          request.headers.fetch('Sub-Domain', '').split(' ').last
        end

        def member_domain(user)
          return unless domain == "#{ENV['MEMBER_WAREHOUSE']}" && user.member?

          domain
        end

        def validate_create_address_params(params)
          phone = params[:phone].to_s.bd_phone
          unless phone
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.invalid_phone'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          district = District.find_by(id: params[:district_id])
          unless district
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.district_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          thana = district.thanas.find_by(id: params[:thana_id])
          unless thana
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.thana_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          area = thana.areas.find_by(id: params[:area_id])
          unless area
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.area_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          existing_address = @current_user.addresses.find_by(title: params[:title].strip)
          if existing_address.present?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.address_title_already_exist'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          { phone: phone, district: district, thana: thana, area: area }
        end

        def validate_update_address_params(address, params)
          phone = if params[:phone].present?
                    phone = params[:phone].to_s.bd_phone
                    unless phone
                      error!(failure_response_with_json(I18n.t('Ecom.errors.messages.invalid_phone'),
                                                        HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                    end
                    phone
                  else
                    address.phone
                  end

          title = if params[:title].present?
                    existing_address = @current_user.addresses.find_by(title: params[:title].strip)
                    if existing_address.present? && existing_address != address
                      error!(failure_response_with_json(I18n.t('Ecom.errors.messages.address_title_already_exist'),
                                                        HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                    end
                    params[:title].strip
                  else
                    address.title
                  end

          district = if params[:district_id].present?
                       district = District.find_by(id: params[:district_id])
                       unless district
                         error!(failure_response_with_json(I18n.t('Ecom.errors.messages.district_not_found'),
                                                           HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
                       end
                       district
                     else
                       address.district
                     end

          thana = if params[:thana_id].present?
                    thana = district.thanas.find_by(id: params[:thana_id])
                    unless thana
                      error!(failure_response_with_json(I18n.t('Ecom.errors.messages.thana_not_found'),
                                                        HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
                    end
                    thana
                  else
                    address.thana
                  end

          area = if params[:area_id].present?
                   area = thana.areas.find_by(id: params[:area_id])
                   unless area
                     error!(failure_response_with_json(I18n.t('Ecom.errors.messages.area_not_found'),
                                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
                   end
                   area
                 else
                   address.area
                 end

          name = params[:name].present? ? params[:name].strip : address.name
          bn_name = params[:bn_name].present? ? params[:bn_name].strip : address.bn_name
          bn_phone = params[:bn_phone].present? ? params[:bn_phone].strip : address.bn_phone
          address_line = params[:address_line].present? ? params[:address_line].strip : address.address_line
          bn_address_line = params[:bn_address_line].present? ? params[:bn_address_line].strip : address.bn_address_line
          zip_code = params[:zip_code].present? ? params[:zip_code] : address.zip_code

          {
            phone: phone, bn_phone: bn_phone, name: name, bn_name: bn_name, title: title, district: district,
            thana: thana, area: area, address_line: address_line, bn_address_line: bn_address_line,
            zip_code: zip_code,
          }
        end
      end

      resource :users do
        desc 'Get logged in user information.'
        get '/current' do
          warehouse = Warehouse.find_by(id: params[:warehouse_id])
          response = Ecommerce::V1::Entities::AccountInformations.represent(@current_user,
                                                                            warehouse: warehouse)
          success_response_with_json(I18n.t('Ecom.success.messages.user_information_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch user information due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_information_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Create a new ecom user.'
        params do
          requires :full_name, type: String
          requires :phone, type: String
          optional :email, type: String
          optional :subscribe, type: Boolean
          requires :gender, type: Integer
          requires :date_of_birth, type: Date
          requires :password, type: String
        end
        route_setting :authentication, optional: true
        post :signup do
          unless params[:password].present? && params[:password].length >= 6
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.min_6_character_password_check'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          phone = params[:phone].to_s.bd_phone
          unless phone
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.invalid_phone'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          email_exist = User.find_by_email(params[:email])
          if email_exist && !params[:email].blank?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.existing_email'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          phone_exist = User.find_by_phone(phone)
          if phone_exist
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.phone_already_registered'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          subscribe_to_newsletter(params[:email]) if params[:subscribe] == true && params[:email].present?

          user = User.create!(
            full_name: params[:full_name],
            phone: phone,
            email: params[:email] || '',
            gender: params[:gender],
            date_of_birth: params[:date_of_birth],
            password: params[:password],
            password_confirmation: params[:password],
          )
          user.update!(otp: user.change_otp)
          message = "Your One Time (OTP) for Shopoth is: #{user.otp}"
          sms_context = SmsManagement::SendMessage.call(phone: user.phone, message: message)
          SmsLogJob.perform_later(SmsLog.sms_types[:otp],
                                  sms_context.phone,
                                  sms_context.message,
                                  sms_context.gateway_response)
          unless sms_context.success?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.otp_send_failed'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          success_response_with_json(I18n.t('Ecom.success.messages.registration_successful'), HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::User.represent(user))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUser registration failed due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.registration_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Ecom user login.'
        params do
          requires :email_or_phone, type: String
          requires :password, type: String
          optional :cart_id, type: Integer
          optional :warehouse_id, type: Integer
        end
        route_setting :authentication, optional: true
        post :sign_in do
          validate_user = User.valid_user?(params[:email_or_phone], params[:password], domain)
          unless validate_user[:success]
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.credential_not_matched'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          user = validate_user[:user]
          unless user.active?
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.credential_not_matched'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          warehouse = Warehouse.find_by(id: params[:warehouse_id])
          if params[:cart_id].present?
            Cart.associate_user_with_cart(params[:cart_id], warehouse, user, member_domain(user))
          end
          token = JsonWebToken.user_token_encode(user)
          success_response_with_json(I18n.t('Ecom.success.messages.signin_successful'),
                                     HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::SignIn.represent(user,
                                                                               token: token,
                                                                               list: true,
                                                                               warehouse: warehouse))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUser login failed due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.login_failed'),
                                            HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
        end

        desc 'Ecom user logout.'
        route_setting :authentication, optional: true
        delete :sign_out do
          bearer_token = request.headers.fetch('Authorization', '').split(' ').last
          if JsonWebToken.remove_token(bearer_token)
            {
              success: true,
              status: 200,
              message: 'Successfully logout',
            }
          else
            error!(failure_response_with_json('Ecommerce user logout failed', HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUser logout failed due to: #{error.message}"
          error!(failure_response_with_json('Ecommerce user logout failed',
                                            HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
        end

        desc 'Verify auth token login user.'
        route_setting :authentication, optional: true
        get :verify_auth_token do
          data = { valid: @current_user.present? }
          success_response_with_json('token info fetched successful',
                                     HTTP_CODE[:OK], data)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch token info to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch token info',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Upload or update user image.'
        params do
          requires :image_file
        end
        put 'image' do
          @current_user.update!(image_file: params[:image_file])
          success_response_with_json(I18n.t('Ecom.success.messages.image_upload_successful'), HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::User.represent(@current_user))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to upload image for user due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.image_upload_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc "Update a specific user's information."
        params do
          optional :full_name, type: String
          optional :email, type: String
          optional :gender, type: Integer
          optional :date_of_birth, type: Date
        end
        put do
          declared_params = declared(params, include_missing: false)
          @current_user.update!(declared_params)
          response = Ecommerce::V1::Entities::AccountInformations.represent(@current_user)
          success_response_with_json(I18n.t('Ecom.success.messages.user_information_update_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update user informations due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_information_update_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'My page password change.'
        params do
          requires :current_password, type: String
          requires :password, type: String
          requires :password_confirmation, type: String
        end
        put 'password' do
          unless @current_user.valid_password?(params[:current_password])
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_current_password_not_matched'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          if params[:current_password] == params[:password]
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_password_and_current_password_same'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          unless params[:password] == params[:password_confirmation]
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.passwords_mismatched'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          declared_params = declared(params, include_missing: false)
          @current_user.update_with_password(declared_params)
          response = Ecommerce::V1::Entities::AccountInformations.represent(@current_user)
          success_response_with_json(I18n.t('Ecom.success.messages.user_password_update_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update user password due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_password_update_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Password change request.'
        params do
          requires :email_or_phone, type: String
        end
        route_setting :authentication, optional: true
        post :secret do
          user = User.find_by_email_or_phone(params[:email_or_phone])
          unless user&.is_otp_verified
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_not_registered'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          if SmsLog.otp.exit_sms_limit?(user.phone)
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.too_many_otp_requests'),
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY], is_restricted: true),
                   HTTP_CODE[:OK])
          end

          otp = JsonWebToken.encode_otp(user)
          unless otp
            error!(failure_response_with_json('OTP sent failed. Please try again!',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          success_response_with_json('Successfully OTP sent.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to send OTP due to: #{error.message}"
          error!(failure_response_with_json('OTP sent failed. Please try again!',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Password change.'
        params do
          requires :email_or_phone, type: String
          requires :otp, type: String
          requires :password, type: String
          requires :password_confirmation, type: String
        end
        route_setting :authentication, optional: true
        put :secret do
          unless params[:password].length >= 6
            return { success: false, status: HTTP_CODE[:NOT_ACCEPTABLE], message: 'Password must be consist of 6 or more characters.', data: [] }
          end

          unless params[:password] == params[:password_confirmation]
            return { success: false, status: HTTP_CODE[:NOT_ACCEPTABLE], message: "Password and Password Confirmation doesn't match.", data: [] }
          end

          user = User.find_by(phone: params[:email_or_phone], otp: params[:otp])
          unless user
            return { success: false, status: HTTP_CODE[:NOT_FOUND], message: "Phone or OTP doesn't match.", data: [] }
          end

          number_of_auth_key = user.authorization_keys&.count
          unless number_of_auth_key.positive?
            return { success: false, status: HTTP_CODE[:NOT_FOUND], message: "Authorization key isn't present.", data: [] }
          end

          user.update!(password: params[:password], password_confirmation: params[:password_confirmation])
          present :success, true
          present :status, HTTP_CODE[:OK]
          present :message, 'Password reset successfully.'
          present :data, []
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to reset password due to: #{error.message}"
          return { success: false, status: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: 'Unable to reset password.', data: [] }
        end

        desc 'Delete a specific user'
        # TODO: Only admin type users should be able soft delete any specific user details
        params do
          requires :password, type: String
          requires :password_confirmation, type: String
        end
        delete do
          # Soft Delete (inactive)
          error!('Not found in Active Users!', 404) if @current_user.inactive?

          if @current_user.update(params.merge(status: :inactive))
            @current_user
          else
            error!(@current_user.errors.messages, 500)
          end
        end

        desc 'Add address for user.'
        params do
          requires :district_id, type: Integer
          requires :thana_id, type: Integer
          requires :area_id, type: Integer
          requires :address_line, type: String
          requires :title, type: String
          requires :phone, type: String
          requires :name, type: String
          optional :zip_code, type: String
        end
        post '/address' do
          address_params = validate_create_address_params(params)
          address = @current_user.addresses.create!(
            district: address_params[:district],
            thana: address_params[:thana],
            area: address_params[:area],
            address_line: params[:address_line],
            title: params[:title].strip,
            phone: address_params[:phone],
            name: params[:name].strip,
            zip_code: params[:zip_code],
          )
          response = Ecommerce::V1::Entities::Address.represent(address)
          success_response_with_json(I18n.t('Ecom.success.messages.user_address_save_successful'),
                                     HTTP_CODE[:CREATED], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to save address due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_address_save_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Edit user address.'
        params do
          optional :district_id, type: Integer
          optional :thana_id, type: Integer
          optional :area_id, type: Integer
          optional :address_line, type: String
          optional :title, type: String
          optional :phone, type: String
          optional :name, type: String
          optional :zip_code, type: String
        end
        put '/address/:id' do
          address = @current_user.addresses.find_by(id: params[:id])
          unless address
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.address_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          address_params = validate_update_address_params(address, params)
          address.update!(address_params)

          response = Ecommerce::V1::Entities::Address.represent(address)
          success_response_with_json(I18n.t('Ecom.success.messages.user_address_update_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update user addresses due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_address_update_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Delete user address.'
        delete '/address/:id' do
          address = @current_user.addresses.find_by(id: params[:id])
          unless address
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.address_not_found'),
                                              HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          address.destroy!
          success_response_with_json(I18n.t('Ecom.success.messages.user_address_delete_successful'),
                                     HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update user addresses due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_address_delete_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get all addresses of user.'
        params do
          optional :filter_by_fc, type: Boolean
          optional :warehouse_id, type: Integer
          optional :district_id, type: Integer
        end
        get '/addresses' do
          addresses = if params[:filter_by_fc]
                        warehouse = Warehouse.find_by(id: params[:warehouse_id])
                        @current_user.addresses.where(district_id: warehouse&.districts&.ids)
                      elsif params[:district_id]
                        @current_user.addresses.where(district_id: params[:district_id])
                      else
                        @current_user.addresses
                      end
          response = Ecommerce::V1::Entities::Address.represent(addresses)
          success_response_with_json(I18n.t('Ecom.success.messages.user_address_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch user addresses due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_address_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        # Add delivery preference for user
        desc 'Add delivery preference'
        params do
          requires :shipping_type, type: String
          requires :pay_type, type: String
          optional :default, type: Boolean
          optional :partner_id, type: Integer
          optional :address_attributes, type: Hash do
            requires :district_id, type: Integer
            requires :thana_id, type: Integer
            requires :area_id, type: Integer
            requires :address_line, type: String
            requires :phone, type: String
            optional :alternative_phone, type: String
            optional :zip_code, type: Integer
          end
        end
        post '/delivery-preferences' do
          if params[:shipping_type] == 'pick_up_point'
            partner = Partner.find(params[:partner_id]) if params[:partner_id].present?
            del_pref = @current_user.delivery_preferences.build(shipping_type: params[:shipping_type],
                                                                pay_type: params[:pay_type],
                                                                partner_id: partner.id)
          else
            del_pref = @current_user.delivery_preferences.build(shipping_type: params[:shipping_type],
                                                                pay_type: params[:pay_type])
            del_pref.build_address(params[:address_attributes])
          end
          del_pref.default = params[:default] if params[:default].present?
          del_pref if del_pref.save!
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Show delivery preference'
        get '/delivery-preferences' do
          pick_up_point = get_pickup_details DeliveryPreference.where(user_id: @current_user.id, shipping_type: 'pick_up_point')
          home_delivery = get_home_delivery_details DeliveryPreference.where(user_id: @current_user.id, shipping_type: 'home_delivery')
          {
            pick_up_point: pick_up_point,
            home_delivery: home_delivery,
          }
        rescue StandardError => error
          error!("unable to fetch #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Fetch wallet amount'
        get :wallet do
          @current_user.wallet&.currency_amount || 0
        rescue StandardError => error
          error!("unable to fetch #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Fetch User coupons'
        get :coupons do
          first_time_reg_coupons = @current_user.customer_orders.blank? ? Coupon.first_registration.active : []
          multi_user_coupons = Coupon.multi_user.active.running(Date.today).where(is_visible: true)
          if multi_user_coupons.present?
            multi_user_coupons = multi_user_coupons.map do |multi_coupon|
              next unless multi_coupon.valid_for_multi_user?(@current_user)

              if multi_coupon.phone_numbers.present?
                next unless multi_coupon.phone_numbers.include?(@current_user.phone)
              end
              multi_coupon
            end.compact
          end
          other_coupons = @current_user.coupons.unused
          coupons = other_coupons + first_time_reg_coupons + multi_user_coupons
          formatted_coupons = Ecommerce::V1::Entities::Coupons.represent(coupons)
          {
            success: true,
            status: HTTP_CODE[:OK],
            message: 'Successfully fetched user coupons',
            data: formatted_coupons,
          }

        rescue StandardError => error
          error!("unable to fetch #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        resources :carts do
          desc 'Delete all carts of the current user'
          delete do
            @current_user&.cart&.destroy
          rescue StandardError => error
            error!("unable to fetch #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        resources :wishlists do
          desc 'Delete all wishlists of the current user'
          delete do
            @current_user.wishlists.destroy_all
          rescue StandardError => error
            error!("unable to fetch #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
