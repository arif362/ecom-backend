# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class Warehouses < ShopothWarehouse::Base
      helpers do
        def json_response(warehouse)
          warehouse.as_json(
            except: %i(created_at updated_at is_deleted warehouse_type capacity),
          )
        end

        def validate_warehouse_update_params(warehouse, params)
          warehouse_type = if params[:warehouse][:warehouse_type].present?
                             unless %w(distribution member b2b).include?(params[:warehouse][:warehouse_type])
                               error!(failure_response_with_json('Please give a valid warehouse type.',
                                                                 HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                             end
                             params[:warehouse][:warehouse_type]
                           else
                             warehouse.warehouse_type
                           end

          phone = if params[:warehouse][:phone].present?
                    phone = params[:warehouse][:phone].to_s.bd_phone
                    unless phone
                      error!(failure_response_with_json('Please provide a valid Bangladeshi phone number.',
                                                        HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                    end
                    phone
                  else
                    warehouse.phone
                  end

          name = params[:warehouse][:name].present? ? params[:warehouse][:name] : warehouse.name
          bn_name = params[:warehouse][:bn_name].present? ? params[:warehouse][:bn_name] : warehouse.bn_name
          email = params[:warehouse][:email].present? ? params[:warehouse][:email] : warehouse.email
          public_visibility = params[:warehouse][:public_visibility].present? ? params[:warehouse][:public_visibility] : warehouse.public_visibility
          is_commission_applicable = params[:warehouse][:is_commission_applicable].present? ? params[:warehouse][:is_commission_applicable] : warehouse.is_commission_applicable

          {
            name: name, bn_name: bn_name, warehouse_type: warehouse_type, email: email, phone: phone,
            public_visibility: public_visibility, is_commission_applicable: is_commission_applicable,
          }
        end

        def validate_warehouse_address_params(warehouse, params, warehouse_params)
          address_line = if params[:warehouse][:address_line].present?
                           params[:warehouse][:address_line]
                         else
                           warehouse.address.address_line
                         end

          area = if params[:warehouse][:area_id].present?
                   area = Area.find_by(id: params[:warehouse][:area_id])
                   unless area
                     error!(failure_response_with_json('Unable to find area.', HTTP_CODE[:NOT_FOUND]),
                            HTTP_CODE[:OK])
                   end
                   area
                 else
                   warehouse.address.area
                 end

          {
            area_id: area.id, thana_id: area.thana_id, district_id: area.thana.district_id,
            default_address: true, name: warehouse_params[:name], phone: warehouse_params[:phone],
            address_line: address_line,
          }
        end

        def update_district_associated_to_warehouse(params, warehouse)
          district_ids = if params[:warehouse][:district_ids].present?
                           districts = District.where(id: params[:warehouse][:district_ids])
                           unless params[:warehouse][:district_ids].size == districts.compact.size
                             error!(failure_response_with_json('Please give valid districts.',
                                                               HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                           end

                           if districts.pluck(:warehouse_id).all?(warehouse.id)
                             warehouse.districts.ids
                           else
                             unless districts.pluck(:warehouse_id).all?(nil)
                               error!(failure_response_with_json('You already have assigned warehouse among these districts.',
                                                                 HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                             end
                             params[:warehouse][:district_ids]
                           end
                         else
                           warehouse.districts.ids
                         end

          District.where(warehouse: warehouse).update_all(warehouse_id: nil)
          districts = District.where(id: district_ids)
          unless districts.count.positive?
            error!(failure_response_with_json('At least one district needed to update warehouse.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          districts.update_all(warehouse_id: warehouse.id)
        end
      end

      # rubocop:disable Metrics/BlockLength
      resource :warehouses do
        # INDEX
        params do
          use :pagination, per_page: 50
        end
        desc 'Get all warehouses.'
        get do
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(Warehouse.includes(:districts, address:
            %i(district thana area)))), with: ShopothWarehouse::V1::Entities::Warehouses
        end

        desc 'Warehouse health check.'
        route_setting :authentication, optional: true
        get '/health_check' do
          respond_with_json('Health is good.Add', HTTP_CODE[:OK])
        end

        params do
          requires :warehouse, type: Hash do
            requires :name, type: String
            requires :bn_name, type: String
            requires :warehouse_type, type: String
            requires :email, type: String
            requires :password, type: String
            requires :password_confirmation, type: String
            optional :phone, type: String
            requires :district_ids, type: Array
            optional :public_visibility, type: Boolean
            optional :is_commission_applicable, type: Boolean
            requires :area_id, type: Integer
            requires :address_line, type: String
          end
        end

        # CREATE
        desc 'Create a new warehouse.'
        post do
          unless check_wh_warehouse
            error!(failure_response_with_json("Distribution warehouse won't be able to create warehouse.",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          districts = District.where(id: params[:warehouse][:district_ids])
          unless params[:warehouse][:district_ids].size == districts.compact.size
            error!(failure_response_with_json('Please give valid districts.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          unless districts.count.positive?
            error!(failure_response_with_json('At least one district needed to create warehouse.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          unless districts.pluck(:warehouse_id).all?(nil)
            error!(failure_response_with_json('You already have assigned warehouse among these districts.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          unless %w(distribution member b2b).include?(params[:warehouse][:warehouse_type])
            error!(failure_response_with_json('Please give a valid warehouse type.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          area = Area.find_by(id: params[:warehouse][:area_id])
          unless area
            error!(failure_response_with_json('Unable to find area.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          warehouse = Warehouse.new(
            name: params[:warehouse][:name],
            bn_name: params[:warehouse][:bn_name],
            warehouse_type: params[:warehouse][:warehouse_type],
            email: params[:warehouse][:email],
            password: params[:warehouse][:password],
            password_confirmation: params[:warehouse][:password_confirmation],
            phone: params[:warehouse][:phone],
            public_visibility: params[:warehouse][:public_visibility],
            is_commission_applicable: params[:warehouse][:is_commission_applicable],
          )

          warehouse.build_address(
            {
              area_id: area.id,
              thana_id: area.thana_id,
              district_id: area.thana.district_id,
              name: params[:warehouse][:name],
              address_line: params[:warehouse][:address_line],
              phone: params[:warehouse][:phone],
              default_address: true,
            },
          )
          warehouse.save!
          districts.update_all(warehouse_id: warehouse.id)
          success_response_with_json('Successfully created warehouse.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create warehouse due to: #{error.message}"
          error!(failure_response_with_json('Unable to create warehouse.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Get Warehouse balance status.'
        get '/warehouse_balance' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
          warehouse = @current_staff.warehouse
          date_range = start_date_time..end_date_time
          unless warehouse
            error!(respond_with_json('Warehouse not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          collected = 0
          warehouse_collectable = 0
          total_return_collectable = []
          total_returned_request = []
          customer_orders = warehouse.customer_orders
          return_customer_orders = warehouse.return_customer_orders.joins(:return_status_changes).where(
            return_status_changes: { created_at: date_range },
          ).includes(:return_status_changes)

          if customer_orders.present?
            warehouse_collectable = customer_orders.joins(:payments).where(
              payments: { created_at: date_range, paymentable_type: %w(User Partner), receiver_type: %w(Rider Route) },
            ).sum('payments.currency_amount')

            collected = customer_orders.joins(:payments).where(
              payments: { created_at: date_range, paymentable_type: %w(Rider Route), receiver_type: 'Staff' },
            ).sum('payments.currency_amount')
          end

          if return_customer_orders.present?
            total_return_collectable = return_customer_orders.where("return_status_changes.status = 'in_transit'")
            total_returned_request = return_customer_orders.where("return_status_changes.status = 'qc_pending'")
          end

          {
            warehouse_cash_collected: collected,
            warehouse_collectable: warehouse_collectable,
            total_returned_request: total_returned_request.size || 0,
            total_return_collectable: total_return_collectable.size || 0,
          }
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch warehouse balance due to: #{error.message}"
          error!(respond_with_json('Unable to fetch warehouse balance.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get distributor balances.'
        params do
          optional :title, type: String
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
          optional :skip_pagination, type: Boolean
          use :pagination, per_page: 50
        end
        get '/distributors' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
          warehouse = @current_staff.warehouse
          distributors = warehouse.distributors
          date_range = start_date_time..end_date_time
          if params[:title].present?
            distributors = distributors.where('LOWER(name) LIKE ?', "#{params[:title].downcase}%")
          end

          unless distributors.present?
            error!(respond_with_json('Distributors not found.', HTTP_CODE[:NOT_FOUND], []),
                   HTTP_CODE[:NOT_FOUND])
          end

          customer_orders = warehouse.customer_orders
          return_customer_orders = warehouse.return_customer_orders
          # TODO: Need to Optimize Query
          distributors = if params[:skip_pagination]
                           distributors
                         else
                           paginate(Kaminari.paginate_array(distributors))
                         end

          response = distributors.map do |distributor|
            d_customer_orders = customer_orders.where(distributor: distributor)
            d_return_orders = return_customer_orders.where(distributor: distributor)
            distributor_collected = d_customer_orders.joins(:payments).where(
              payments: { created_at: date_range, paymentable_type: %w(Rider Route), receiver_type: 'Staff' },
            ).sum('payments.currency_amount')
            distributor_collectable = d_customer_orders.joins(:payments).where(
              payments: { created_at: date_range, paymentable_type: %w(User Partner), receiver_type: %w(Rider Route) },
            ).sum('payments.currency_amount')
            total_return_collected = d_return_orders.joins(:return_status_changes).where(
              return_status_changes: { created_at: date_range, status: 'delivered_to_dh' },
            ).size
            total_return_collectable = d_return_orders.joins(:return_status_changes).where(
              return_status_changes: { created_at: date_range, status: 'in_transit' },
            ).size
            {
              name: distributor.name || '',
              bn_name: distributor.bn_name || '',
              phone: distributor.phone || '',
              email: distributor.email || '',
              distributor_collected: distributor_collected,
              distributor_collectable: distributor_collectable,
              total_return_collected: total_return_collected || 0,
              total_return_collectable: total_return_collectable || 0,
            }
          end.compact

          success_response_with_json('Successfully fetched distributor balances.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch distributor balances due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch distributor balances.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY], []), HTTP_CODE[:OK])
        end

        # Rider List with Pagination ***********
        desc 'Rider list with pagination.'
        params do
          use :pagination, per_page: 50
        end

        get '/riders' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : (Date.today - 1.months).to_datetime.utc
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : Date.today.to_datetime.utc
          status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          riders = check_dh_warehouse ? @current_staff.warehouse.riders : Rider.all
          # riders = Rider.filter_with_date_time(riders, status, start_date_time, end_date_time)
          customer_orders = @current_staff.warehouse.customer_orders
          riders = Rider.filter_with_date_range(customer_orders, riders, start_date_time.to_date.beginning_of_day, end_date_time.to_date.end_of_day)
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(riders)), with: ShopothWarehouse::V1::Entities::ReconciliationRiders
        end

        # Route List with Pagination ***********
        desc 'Route list with pagination.'
        params do
          use :pagination, per_page: 50
        end
        get '/routes' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          routes = check_dh_warehouse ? Route.unscoped.where(warehouse: @current_staff.warehouse) : Route.unscoped
          routes = params[:title].present? ? routes.where('LOWER(title) LIKE ?', "%#{params[:title].downcase}%") : routes
          routes = params[:distributor_id].present? ? routes.where(distributor_id: params[:distributor_id]) : routes
          customer_orders = @current_staff.warehouse.customer_orders
          routes = Route.filter_with_date_range(customer_orders, routes, start_date_time..end_date_time)
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(routes.sort_by { |r| r.title.strip.downcase })), with: ShopothWarehouse::V1::Entities::ReconciliationRoutes
        end

        get '/riders_export' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : (Date.today - 1.months).to_datetime.utc
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : Date.today.to_datetime.utc
          status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          riders = check_dh_warehouse ? @current_staff.warehouse.riders : Rider.all
          customer_orders = @current_staff.warehouse.customer_orders
          riders = Rider.filter_with_date_range(customer_orders, riders, start_date_time.to_date.beginning_of_day, end_date_time.to_date.end_of_day)
          present riders, with: ShopothWarehouse::V1::Entities::ReconciliationRiders
        end

        desc 'Route list export.'
        get '/routes_export' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          routes = check_dh_warehouse ? Route.unscoped.where(warehouse: @current_staff.warehouse) : Route.unscoped
          routes = params[:title].present? ? routes.where('LOWER(title) LIKE ?', "%#{params[:title].downcase}%") : routes
          routes = params[:distributor_id].present? ? routes.where(distributor_id: params[:distributor_id]) : routes
          customer_orders = @current_staff.warehouse.customer_orders
          routes = Route.filter_with_date_range(customer_orders, routes, start_date_time..end_date_time)
          present routes.sort_by { |r| r.title.strip.downcase }, with: ShopothWarehouse::V1::Entities::ReconciliationRoutes
        end

        desc 'Save Warehouse collect history.'
        post '/warehouse_history' do
          warehouse = @current_staff.warehouse
          date = Time.now.utc.to_date
          warehouse.create_wallet(currency_amount: 0.0, currency_type: 'Tk.') if @current_staff.warehouse.wallet.nil?
          if WarehouseCollectHistory.find_collect_history(warehouse, date).present?
            error!(respond_with_json('Warehouse collect history already saved.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:NOT_ACCEPTABLE])
          else
            WarehouseCollectHistory.create!(
              warehouse_id: warehouse.id,
              cash: warehouse.collected_cash_from_routes,
              wallet: warehouse.wallet.currency_amount,
              return: warehouse.return_count,
              collect_date: date,
            )
            warehouse.update(
              collected_cash_from_routes: 0.0,
              return_count: 0,
            )
            warehouse.wallet.update(currency_amount: 0.0)
            respond_with_json('Warehouse history has been saved.', HTTP_CODE[:OK])
          end
        rescue
          error!(respond_with_json("Failed: Can't close due to Bad network.", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'get a warehouse'
        params do
          requires :id, type: Integer, desc: 'warehouse id'
        end

        route_param :id do
          get do
            warehouse = Warehouse.find(params[:id])
            present warehouse, with: ShopothWarehouse::V1::Entities::Warehouses if warehouse.present?
          rescue StandardError => error
            error! respond_with_json("Unable to find warehouse with id #{params[:id]} due to #{error.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end
        end

        # UPDATE
        desc 'Update a warehouse.'
        put ':id' do
          unless check_wh_warehouse
            error!(failure_response_with_json("Distribution warehouse won't be able to create warehouse.",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          warehouse = Warehouse.find_by(id: params[:id])
          unless warehouse
            error!(failure_response_with_json('Warehouse not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          warehouse_params = validate_warehouse_update_params(warehouse, params)
          warehouse_address_params = validate_warehouse_address_params(warehouse, params, warehouse_params)

          if params[:warehouse][:password].present? && params[:warehouse][:password].size >= 6 && params[:warehouse][:password] == params[:warehouse][:password_confirmation]
            warehouse.update!(
              password: params[:warehouse][:password],
              password_confirmation: params[:warehouse][:password_confirmation],
            )
          elsif params[:warehouse][:password].present? && params[:warehouse][:password] != params[:warehouse][:password_confirmation]
            error!(failure_response_with_json('Password and password confirmation not matched.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end

          warehouse.update!(warehouse_params)
          warehouse.address.update!(warehouse_address_params)
          update_district_associated_to_warehouse(params, warehouse)
          success_response_with_json('Successfully updated warehouse.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update warehouse due to: #{error.message}"
          error!(failure_response_with_json('Unable to update warehouse.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        # DELETE
        desc 'Delete a warehouse'
        route_param :id do
          delete do
            warehouse = Warehouse.find(params[:id])
            warehouse.soft_delete if warehouse.present?
            respond_with_json("Successfully deleted Warehouse with id #{params[:id]}", HTTP_CODE[:OK])
          rescue StandardError
            error! respond_with_json('Unable to delete Warehouse.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        route_param :id do
          desc 'get partners margin list'
          params do
            use :pagination, per_page: 25
            requires :month, type: Integer
            requires :year, type: Integer
            optional :skip_pagination, type: Boolean
          end
          get 'partners_margin' do
            warehouse = Warehouse.find params[:id]
            return [] unless warehouse.present?

            start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
            end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
            completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
            partial_return_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
            orders = warehouse.customer_orders.where(status: [completed_status, partial_return_status], completed_at: start_date..end_date)

            orders = orders.order(created_at: :desc).select { |order| (order.induced? || (order.organic? && order.pick_up_point?)) && order.aggregated_transaction_customer_orders.agent_commission.blank? }

            if orders.present?
              # TODO: Need to Optimize Query
              orders = paginate(Kaminari.paginate_array(orders)) unless params[:skip_pagination].present?
              present orders, with: ShopothWarehouse::V1::Entities::PartnerMargin
            else
              status :not_found
              { status_code: HTTP_CODE[:NOT_FOUND], message: 'Customer orders not found' }
            end
          rescue => ex
            error! respond_with_json("Unable to fetch order list due to #{ex.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end

          desc 'get agent commission list'
          params do
            use :pagination, per_page: 25
            requires :month, type: Integer
            requires :year, type: Integer
            optional :skip_pagination, type: Boolean
          end
          get 'agent_commission' do
            warehouse = Warehouse.find params[:id]
            return [] unless warehouse.present?

            start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
            end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
            completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
            partial_return_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
            orders = warehouse.customer_orders.where(status: [completed_status, partial_return_status], completed_at: start_date..end_date)
            orders = orders.order(created_at: :desc).select { |order| order.aggregated_transaction_customer_orders.agent_commission.blank? }

            if orders.present?
              # TODO: Need to Optimize Query
              orders = paginate(Kaminari.paginate_array(orders)) unless params[:skip_pagination].present?
              present orders, with: ShopothWarehouse::V1::Entities::AgentCommission
            else
              status :not_found
              { status_code: HTTP_CODE[:NOT_FOUND], message: 'Customer orders not found' }
            end
          rescue => ex
            error! respond_with_json("Unable to fetch order list due to #{ex.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end
        end
      end
    end
  end
end
