module ShopothWarehouse
  module V1
    class RouteDevices < ShopothWarehouse::Base
      helpers do
        def select_payment_status(partner)
          customer_orders = partner.customer_orders.where(shipping_type: 'pick_up_point')
          customer_orders.select do |customer_order|
            customer_order.pay_status == 'partner_paid'
          end
        end

        def schedule_matched?(partner)
          partner_schedule = partner.schedule
          current_day = Date.today.strftime("%A")[0..2].downcase
          partner_schedule.include?(current_day)
        end

        def fetch_extendable_facility(order)
          order_status_change = order.customer_order_status_changes.find_by(order_status: order_status)
          return -1 unless order_status_change.present?

          (Date.today - order_status_change.created_at.to_date).to_i
        end

        def order_status
          OrderStatus.find_by(order_type: 'delivered_to_partner')
        end

        def json_response(route_device)
          route_device.as_json(
            except: %i(created_at updated_at),
            )
        end
      end
      resource :route_devices do

        desc 'Get in_partner order list for SR.'
        route_setting :authentication, type: RouteDevice
        params do
          optional :partner_id, type: Integer
        end
        get '/get_in_partner_list' do
          partners = @current_route_device.route.partners
          in_partner_orders = []
          status = OrderStatus.getOrderStatus(OrderStatus.order_types[:delivered_to_partner])
          if partners.present?
            partners = partners.where(id: params[:partner_id]) if params[:partner_id].present?
            partners.each do |partner|
              next unless schedule_matched?(partner)

              in_partner_orders << partner.customer_orders&.where(order_status_id: status.id)
            end
            present :success, true
            present :message, 'Successfully fetched.'
            present :status_code, HTTP_CODE[:OK]
            present :data, in_partner_orders.flatten.compact.sort, with:
              ShopothWarehouse::V1::Entities::InPartnerOrders
          else
            present :success, false
            present :message, 'Route or Partners not present.'
            present :status_code, HTTP_CODE[:NOT_FOUND]
            present :data, []
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch in_partner customer orders due to: #{error.message}"
          error!(respond_with_json('Unable to fetch in_partner customer orders.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # CREATE ************************************************
        desc 'Connect RouteDevice'
        params do
          requires :route_device, type: Hash do
            requires :unique_id, type: String
            requires :password_hash, type: String
            requires :route_id, type: Integer
          end
        end

        post '/connect' do
          if check_wh_warehouse
            error!(respond_with_json('You are not allowed to connect any devise',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          route_device = RouteDevice.find_by(unique_id: params[:route_device][:unique_id])
          route = Route.find(params[:route_device][:route_id])
          if route.present? && route_device.present?
            route_device.update(route: route, password: params[:route_device][:password_hash])
            json_response(route_device)
          end
        rescue StandardError => error
          error!(respond_with_json("Unable to connect route_device due to #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end


        desc 'Add bKash number to SR profile.'
        params do
          requires :bkash_number, type: String
        end
        route_setting :authentication, type: RouteDevice
        put '/add_bkash_number' do
          sr = @current_route_device&.route
          unless sr
            error!(respond_with_json(I18n.t('Sr.errors.messages.sr_not_found'), HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end
          if sr&.bkash_number.present?
            error!(respond_with_json(I18n.t('Sr.errors.messages.bkash_already_taken'), HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:OK])
          end
          sr.update!(bkash_number: params[:bkash_number])
          success_response_with_json(I18n.t('Sr.success.messages.add_bkash_number_successfully'), HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to add bKash number due to: #{error.message}"
          error!(respond_with_json(I18n.t('Sr.errors.messages.add_bkash_number_error'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        # connect device with route
        desc 'Update route_id'
        route_param :id do
          put '/update' do
            route_device = RouteDevice.find(params[:id])
            route_device if route_device.update!(params[:route_device])
            respond_with_json("Update Success!", HTTP_CODE[:OK])
          rescue StandardError => error
            error!("Cannot update route_id due to #{error.message}")
          end
        end

        # discounect device from route
        desc 'Disconnect'
        route_param :id do
          put '/disconnect' do
            if check_wh_warehouse
              error!(respond_with_json('You are not allowed to disconnect any devise',
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            route_device = RouteDevice.find_by(route_id: params[:id])
            route_device.route_id = nil
            route_device.save!
            respond_with_json("Disconect Success!", HTTP_CODE[:OK])
          rescue StandardError => error
            error!(respond_with_json("Cannot disconnect route_id due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Sell To Partner After Expiration.'
        params do
          requires :order_id, type: Integer
        end
        route_setting :authentication, type: RouteDevice
        put '/sell_order' do
          customer_order = CustomerOrder.find_by(id: params[:order_id])
          if customer_order.present?
            route = @current_route_device&.route
            customer_order.partner.payments.create(currency_amount: customer_order.total_price,
                                                   currency_type: 'BDT',
                                                   status: :successful,
                                                   form_of_payment: :cash,
                                                   customer_order_id: customer_order.id,
                                                   receiver_id: route.id,
                                                   receiver_type: route.class.to_s)
            customer_order.update(pay_status: :partner_paid,
                                  status: OrderStatus.getOrderStatus(OrderStatus.order_types[:sold_to_partner]))
            route.update(cash_amount: (route&.cash_amount.to_d + customer_order&.total_price.to_d))

            app_notification = AppNotification.order_purchase_by_partner(customer_order)
            PushNotification::CreateAppNotifications.call(
              app_user: customer_order.partner,
              title: app_notification[:title],
              bn_title: app_notification[:bn_title],
              message: app_notification[:message],
              bn_message: app_notification[:bn_message])

            app_notification = AppNotification.order_sold_partner(customer_order)
            PushNotification::CreateAppNotifications.call(
              app_user: route,
              title: app_notification[:title],
              bn_title: app_notification[:bn_title],
              message: app_notification[:message],
              bn_message: app_notification[:bn_message])

            status :ok
            respond_with_json('Success', HTTP_CODE[:OK])
          else
            error! respond_with_json('Order not found', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError => error
          error! respond_with_json("Failed : #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # change password of route device
        desc 'Update a specific route_device'
        route_param :id do
          put do
            route_device = RouteDevice.find(params[:id])
            if route_device.unique_id == params[:route_device][:unique_id]
              route_device.update(params[:route_device])
              route_device.as_json(except: [:created_at, :updated_at, :password_hash])
            end
          rescue StandardError => error
            error!("Cannot update route_device due to #{error.message}")
          end
        end

        route_setting :authentication, optional: true
        # create/find route device API
        post '/search' do
          params do
            requires :device_id, type: String
          end
          route_device = RouteDevice.find_or_create_by(device_id: params[:device_id])

          if route_device.route.present?
            status :ok
            {
              connected: true,
              route_title: route_device&.route&.title,
              dh_name: route_device&.route&.distributor&.warehouse&.name
            }
          else
            status :not_found
            {
              connected: false,
              pin: route_device&.unique_id
            }
          end
        rescue StandardError => error
          error!("Connected False #{error.message}")
        end

        # List **********************************************
        get do
          route_devices = RouteDevice.all
          sorted_route_devices = route_devices.order(created_at: :desc)
          paginate(sorted_route_devices.as_json(except: [:created_at, :updated_at, :password_hash]))
        end

        route_setting :authentication, optional: true
        # RouteDevice Login
        post '/login' do
          params do
            requires :device_id, type: String
            requires :password, type: String
          end
          route_device = RouteDevice.find_by(device_id: params[:device_id])
          if route_device&.password == params[:password]
            route_device.route.create_app_config() if route_device.route.app_config.nil?
            route_device.route.app_config.update!(fcm_token: request.headers['Fcm-Token']) if request.headers['Fcm-Token'].present?
            status :ok
            {
              auth_token: JsonWebToken.login_token_encode(route_device),
              sr_name: route_device&.route&.sr_name,
              sr_point: route_device&.route&.sr_point,
              sr_id: route_device&.route&.title,
              distributor_name: route_device&.route&.distributor&.name,
              bkash_number: route_device&.route&.bkash_number
            }
          else
            status :unprocessable_entity
            {
              error: 'Invalid device_id or password',
            }
          end
        end

        desc 'Get payment list for SR.'
        route_setting :authentication, type: RouteDevice
        params do
          optional :partner_id, type: Integer
        end
        get '/get_payment_list' do
          partners = @current_route_device.route.partners
          payment_orders = []
          payment_status = %w(non_extended customer_paid extended extension_expired)
          order_status = OrderStatus.where(order_type: %w(completed returned_from_customer partially_returned)).ids
          if partners.present?
            partners = partners.where(id: params[:partner_id]) if params[:partner_id].present?
            partners.each do |partner|
              next unless schedule_matched?(partner)

              partner.customer_orders.where(order_status_id: order_status, pay_status: payment_status).each do |order|
                extendable = fetch_extendable_facility(order)
                payment_orders << order.as_json.merge(extendable_days: extendable).with_indifferent_access
              end
            end
            status :ok
            present payment_orders.compact.sort_by { |order| order['id'] }, with:
              ShopothWarehouse::V1::Entities::PartnerPayments
          else
            status :unprocessable_entity
            {
              error: 'Route or Partners not present!',
            }
          end
        end

        route_setting :authentication, type: RouteDevice
        get '/get_payment_list_history' do
          partner_id = params[:partner_id]
          payment_list = if partner_id.present?
                           partner = Partner.find(partner_id)
                           select_payment_status(partner)
                         else
                           partners = @current_route_device.route.partners
                           partners.map do |partner|
                             select_payment_status(partner)
                           end.flatten.compact
                         end
          present payment_list, with: ShopothWarehouse::V1::Entities::PaymentListHistory
        end
      end
    end
  end
end
