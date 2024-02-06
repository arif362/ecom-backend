module ShopothWarehouse
  module V1
    class Partners < ShopothWarehouse::Base
      helpers ::ShopothWarehouse::V1::NamedParams::Partners

      SR_STATUS = %w(ready_to_shipment in_transit in_transit_partner_switch)

      helpers do
        def select_customer_orders(partner)
          partner.customer_orders.select do |order|
            order.shipping_type == 'pick_up_point' &&
              SR_STATUS.include?(order.status.order_type)
          end
        end

        def select_delivery_history(partner)
          partner.customer_orders.select do |order|
            order.shipping_type == 'pick_up_point' &&
              %w(completed delivered_to_partner).include?(order.status.order_type.to_s)
          end
        end

        def schedule_matched?(partner)
          partner_schedule = partner.schedule
          current_day = Date.today.strftime("%A")[0..2].downcase
          partner_schedule.include?(current_day)
        end

        def fetch_partners_by_route
          @current_staff&.warehouse&.routes.map do |route|
            route.partners&.order(created_at: :desc)
          end.flatten.compact
        end

        def fetch_partners_by_warehouse
          @current_staff.warehouse.partners&.left_joins(customer_orders: %i(customer_order_status_changes payments))&.
            distinct&.includes(customer_orders: :payments)
        end

        def collected_by_sr(customer_orders)
          customer_orders.joins(:payments).
            where(payments: { status: :successful, paymentable_type: 'Partner', receiver_type: 'Route' }).
            sum('payments.currency_amount') || 0
        end

        # def due_amount(customer_orders)
        #   customer_orders.where(order_status_id: [7, 8], pay_type: 'cash_on_delivery').
        #     where.not(pay_status: [CustomerOrder.pay_statuses[:partner_paid],
        #                            CustomerOrder.pay_statuses[:dh_received],])&.sum(:total_price) || 0
        # end

        def validate_partner_create_params(params)
          phone = params[:partner][:phone].to_s.bd_phone
          unless phone
            error!(failure_response_with_json('Please provide a valid Bangladeshi phone number.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          existing_partner = Partner.find_by_phone(phone)
          if existing_partner
            error!(failure_response_with_json('Phone number already exists.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end

          existing_partner_slug = Partner.find_by(slug: params[:partner][:slug].to_s.downcase.parameterize)
          if existing_partner_slug
            error!(failure_response_with_json('Slug already exists, please give another slug.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          route = @current_staff.warehouse.routes.find_by(id: params[:partner][:route_id])
          unless route
            error!(failure_response_with_json('Route not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          status = params[:partner][:status].present? ? params[:partner][:status] : 'active'
          days = Array.new(7, { is_opened: false })
          if params[:partner][:work_days].present?
            params[:partner][:work_days].each do |day|
              if (day[:day_index]).negative? || day[:day_index] > 6
                error!(failure_response_with_json('Please give valid week days.', HTTP_CODE[:NOT_ACCEPTABLE]),
                       HTTP_CODE[:OK])
              end

              next unless day[:is_opened]

              unless Time.valid?(day[:opening_time]) && Time.valid?(day[:closing_time])
                error!(failure_response_with_json("Please give valid day time of #{Date::DAYNAMES[day[:day_index]]}.",
                                                  HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
              end

              unless Time.parse(day[:opening_time]) < Time.parse(day[:closing_time])
                error!(failure_response_with_json('Partner shop opening time will be grater than closing time.',
                                                  HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
              end

              days[day[:day_index]] = {
                is_opened: true,
                opening_time: day[:opening_time],
                closing_time: day[:closing_time],
              }
            end
          end
          is_commission_applicable = params[:partner][:is_commission_applicable] & true
          meta_datum_attributes = params[:partner][:meta_datum_attributes] || {}

          {
            phone: phone, route: route, name: params[:partner][:name], password: params[:partner][:password],
            password_confirmation: params[:partner][:password_confirmation], email: params[:partner][:email],
            status: status, schedule: params[:partner][:schedule], slug: params[:partner][:slug].strip,
            tsa_id: params[:partner][:tsa_id], retailer_code: params[:partner][:retailer_code],
            partner_code: params[:partner][:partner_code], region: params[:partner][:region],
            area: params[:partner][:area], territory: params[:partner][:territory],
            owner_name: params[:partner][:owner_name], cluster_name: params[:partner][:cluster_name],
            sub_channel: params[:partner][:sub_channel], latitude: params[:partner][:latitude],
            longitude: params[:partner][:longitude], bn_name: params[:partner][:bn_name],
            point: params[:partner][:point], work_days: days, image_file: params[:partner][:image_file],
            meta_datum_attributes: meta_datum_attributes,
            is_commission_applicable: is_commission_applicable,
            business_type: params[:partner][:business_type],
          }
        end

        def validate_partner_update_params(partner, params)
          phone = if params[:partner][:phone].present?
                    phone = params[:partner][:phone].to_s.bd_phone
                    unless phone
                      error!(failure_response_with_json('Please provide valid Bangladeshi phone number.',
                                                        HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                    end

                    existing_partner = Partner.find_by_phone(phone)
                    if existing_partner.present? && existing_partner != partner
                      error!(failure_response_with_json('This number is already been taken.',
                                                        HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                    end
                    phone
                  else
                    partner.phone
                  end

          slug = if params[:partner][:slug].present?
                   existing_partner = Partner.find_by(slug: params[:partner][:slug].to_s.downcase.parameterize)
                   if existing_partner.present? && existing_partner != partner
                     error!(failure_response_with_json('Slug already exists, please give another slug.',
                                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                   end
                   params[:partner][:slug].strip
                 else
                   partner.slug.strip
                 end

          route = if params[:partner][:route_id].present?
                    route = @current_staff.warehouse.routes.find_by(id: params[:partner][:route_id])
                    unless route
                      error!(failure_response_with_json('Route not found.', HTTP_CODE[:NOT_FOUND]),
                             HTTP_CODE[:OK])
                    end

                    if partner.route != route && partner.customer_orders.present?
                      error!(failure_response_with_json("Route can't be changed because partner has customer orders.",
                                                        HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                    end

                    route
                  else
                    partner.route
                  end

          days = if params[:partner][:work_days].present?
                   days = Array.new(7, { is_opened: false })
                   params[:partner][:work_days].each do |day|
                     if (day[:day_index]).negative? || day[:day_index] > 6
                       error!(failure_response_with_json('Please give valid week days.',
                                                         HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                     end

                     next unless day[:is_opened]

                     unless Time.valid?(day[:opening_time]) && Time.valid?(day[:closing_time])
                       error!(failure_response_with_json("Please give valid day time of #{Date::DAYNAMES[day[:day_index]]}.",
                                                         HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                     end

                     unless Time.parse(day[:opening_time]) < Time.parse(day[:closing_time])
                       error!(failure_response_with_json('Partner shop opening time will be grater than closing time.',
                                                         HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
                     end

                     days[day[:day_index]] = {
                       is_opened: true,
                       opening_time: day[:opening_time],
                       closing_time: day[:closing_time],
                     }
                   end
                   days
                 else
                   partner.work_days
                 end

          partner_code = params[:partner][:partner_code].present? ? params[:partner][:partner_code] : partner.partner_code
          if partner_code.blank?
            error!(failure_response_with_json('Please provide partner code.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          name = params[:partner][:name].present? ? params[:partner][:name] : partner.name
          schedule = params[:partner][:schedule].present? ? params[:partner][:schedule] : partner.schedule
          status = params[:partner][:status].present? ? params[:partner][:status] : partner.status
          tsa_id = params[:partner][:tsa_id].present? ? params[:partner][:tsa_id] : partner.tsa_id
          retailer_code = params[:partner][:retailer_code].present? ? params[:partner][:retailer_code] : partner.retailer_code
          region = params[:partner][:region].present? ? params[:partner][:region] : partner.region
          area = params[:partner][:area].present? ? params[:partner][:area] : partner.area
          territory = params[:partner][:territory].present? ? params[:partner][:territory] : partner.territory
          owner_name = params[:partner][:owner_name].present? ? params[:partner][:owner_name] : partner.owner_name
          cluster_name = params[:partner][:cluster_name].present? ? params[:partner][:cluster_name] : partner.cluster_name
          sub_channel = params[:partner][:sub_channel].present? ? params[:partner][:sub_channel] : partner.sub_channel
          latitude = params[:partner][:latitude].present? ? params[:partner][:latitude] : partner.latitude
          longitude = params[:partner][:longitude].present? ? params[:partner][:longitude] : partner.longitude
          bn_name = params[:partner][:bn_name].present? ? params[:partner][:bn_name] : partner.bn_name
          point = params[:partner][:point].present? ? params[:partner][:point] : partner.point
          email = params[:partner][:email].present? ? params[:partner][:email] : partner.email
          is_commission_applicable = params[:partner][:is_commission_applicable].to_s.present? ? params[:partner][:is_commission_applicable] : partner.is_commission_applicable
          meta_datum_attributes = params[:partner][:meta_datum_attributes] || {}
          {
            phone: phone, route: route, name: name, email: email, status: status, schedule: schedule,
            tsa_id: tsa_id, retailer_code: retailer_code, partner_code: partner_code, region: region,
            area: area, territory: territory, owner_name: owner_name, cluster_name: cluster_name,
            sub_channel: sub_channel, latitude: latitude, longitude: longitude, bn_name: bn_name,
            point: point, work_days: days, slug: slug,
            is_commission_applicable: is_commission_applicable,
            meta_datum_attributes: meta_datum_attributes,
            business_type: params[:partner][:business_type],
          }
        end

        def create_or_update_address(partner, address_attributes)
          area = Area.find_by(id: address_attributes[:area_id])
          unless partner.route.distributor.thanas.find_by(id: area.thana_id)
            error!(failure_response_with_json("Thana isn't in the distributor territory.",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          if partner.address.present?
            partner.address.update!(area_id: area.id, thana_id: area.thana_id, name: partner.name,
                                    phone: partner.phone, district_id: area.thana.district_id,
                                    address_line: address_attributes[:address_line])
          else
            partner.create_address(
              area_id: area.id,
              thana_id: area.thana_id,
              district_id: area.thana.district_id,
              name: partner.name,
              address_line: address_attributes[:address_line],
              phone: partner.phone,
              default_address: true,
            )
          end
        end
      end

      resource :partners do
        desc 'Partner list by area'
        params do
          use :partner_list_by_area
        end
        get '/location' do
          area = Area.find(params[:area_id])
          partners = Partner.find_by_area(area.id) if area.present?
          present partners, with: ShopothWarehouse::V1::Entities::Partners
        rescue => error
          error! respond_with_json("Unable to fetch #{error.message}", HTTP_CODE[:NOT_FOUND])
        end

        desc 'fetch delivery list.'
        params do
          use :fetch_delivery_list
        end

        route_setting :authentication, type: RouteDevice
        get 'delivery_list' do
          partner_id = params[:partner_id]
          customer_orders = if partner_id.present?
                              partner = @current_route_device.route.partners.find(partner_id)
                              return [] unless schedule_matched?(partner)

                              select_customer_orders(partner)
                            else
                              partners = @current_route_device.route&.partners
                              partners.map do |partner|
                                next unless schedule_matched?(partner)

                                select_customer_orders(partner)
                              end.flatten.compact
                            end
          return [] unless customer_orders.present?

          present customer_orders.sort, with: ShopothWarehouse::V1::Entities::DeliveryList
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch delivery list due to: #{error.message}"
          error! respond_with_json('Unable to fetch delivery list.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Return delivery history list.'
        params do
          use :return_delivery_history_list
        end
        route_setting :authentication, type: RouteDevice
        get '/delivery/history' do
          partner_id = params[:partner_id]
          customer_orders = if partner_id.present?
                              partner = Partner.find(partner_id)
                              select_delivery_history(partner)
                            else
                              partners = @current_route_device.route&.partners
                              partners.map do |partner|
                                select_delivery_history(partner)
                              end.flatten.compact
                            end
          present customer_orders, with: ShopothWarehouse::V1::Entities::DeliveryList
        rescue => error
          error! respond_with_json("Unable to fetch delivery list due to #{error.message}",
                                   HTTP_CODE[:NOT_FOUND])
        end

        route_param :id do
          desc 'Get partner Order completion list.'
          params do
            use :partner_order_completion_list
          end

          get 'completed_orders' do
            partner = Partner.find(params[:id])
            respond_with_json('Partner not found.', HTTP_CODE[:NOT_FOUND]) unless partner.present?

            start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
            end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
            completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
            partial_return_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
            customer_orders = partner.customer_orders.where(status: [completed_status, partial_return_status], completed_at: start_date..end_date)
            present customer_orders, with: ShopothWarehouse::V1::Entities::CustomerOrderWithMargin
          rescue
            error!(respond_with_json('Failed to fetch partner order list.', HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Get all partners.'
        params do
          use :list_of_partner_params
        end
        get do
          result = []
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_month : Time.now.utc.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.utc.end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a  range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          status = OrderStatus.find_by(order_type: params[:status]) if params[:status] == 'completed'
          partners = if check_dh_warehouse
                       fetch_partners_by_warehouse
                     else
                       Partner.left_joins(customer_orders: %i(customer_order_status_changes payments)).
                         distinct.includes(customer_orders: :payments)
                     end

          partners = partners.where('partners.phone = ?', params[:phone]) if params[:phone].present?
          partners = partners.where('partners.route_id = ?', params[:route_id]) if params[:route_id].present?
          if params[:partner_code].present?
            partners = partners.where('partners.partner_code = ?', params[:partner_code])
          end
          # TODO: Need to Optimize Query
          paginate(Kaminari.paginate_array(partners))&.each do |partner|
            customer_orders = partner.customer_orders.joins(customer_order_status_changes: :order_status).where(
              'customer_orders.order_status_id IN (7, 8)',
            ).where('order_statuses.order_type IN (6) AND (customer_order_status_changes.created_at BETWEEN ? AND ?)', start_date_time, end_date_time)
            customer_orders = customer_orders.where(order_status_id: status.id) if status.present?
            return_orders = partner.return_customer_orders.where(
              'return_customer_orders.return_status IN (0, 1) AND return_customer_orders.created_at BETWEEN ? AND ?', start_date_time, end_date_time
            )
            unless status.present?
              return_customer_order_ids = ReturnCustomerOrder.packed.where('customer_order_id in (?)', customer_orders.ids).pluck(:customer_order_id)
              customer_orders = customer_orders.where('customer_orders.id NOT IN (?)', return_customer_order_ids) if return_customer_order_ids.present?
            end
            result.append(fetch_customer_orders(partner, customer_orders, return_orders))
          end
          result
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch partners due to: #{error.message}"
          error!(respond_with_json("Unable to find partner due to #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get all partners for export'
        get '/export' do
          result = []
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : 1.month.ago
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : Time.now
          status = OrderStatus.find_by(order_type: params[:status]) if params[:status] == 'completed'

          partners = if check_dh_warehouse
                       fetch_partners_by_warehouse
                     else
                       Partner.left_joins(customer_orders: %i(customer_order_status_changes payments)).
                         distinct.includes(customer_orders: :payments)
                     end

          partners = partners.where("partners.phone = ?", params[:phone]) if params[:phone].present?
          partners = partners.where("partners.route_id = ?", params[:route_id]) if params[:route_id].present?
          partners = partners.where("partners.partner_code = ?", params[:partner_code]) if params[:partner_code].present?
          partners&.each do |partner|
            customer_orders = partner.customer_orders.where('customer_orders.order_status_id IN (7, 8)')
            customer_orders = customer_orders.where(order_status_id: status.id) if status.present?
            return_orders = partner.return_customer_orders.where(return_status: [0, 1])

            if start_date_time.present? && end_date_time.present?
              # TODO: max 3 month time range validation
              return_orders = return_orders.where('created_at BETWEEN ? AND ?', start_date_time.to_date.beginning_of_day, end_date_time.to_date.end_of_day)
              customer_orders = customer_orders.joins(customer_order_status_changes: :order_status).
                                where('order_statuses.order_type IN (6) AND
                                customer_order_status_changes.created_at >= ? AND
                                customer_order_status_changes.created_at <= ?', start_date_time.to_date.beginning_of_day, end_date_time.to_date.end_of_day)
            end
            result.append(fetch_customer_orders(partner, customer_orders, return_orders))
          end
          result
        rescue => error
          error!(respond_with_json("Unable to find partner due to #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get a specific partner details.'
        get ':id' do
          partner = Partner.find_by(id: params[:id])
          unless partner
            error!(failure_response_with_json('Unable to find partner.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          success_response_with_json('Successfully fetched partner details.', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Partners.represent(partner))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch details of a partner due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch details of a partner.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Create a new partner.'
        params do
          use :create_partner_params
        end

        post do
          if check_wh_warehouse
            error!(failure_response_with_json("Central warehouse can't create partner.",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          partner_params = validate_partner_create_params(params)
          partner = Partner.new(partner_params.merge!(created_by_id: @current_staff.id))
          area = Area.find_by(id: params[:address_attributes][:area_id])
          partner.build_address(
            {
              area_id: area.id,
              thana_id: area.thana_id,
              district_id: area.thana.district_id,
              name: partner.name,
              address_line: params[:address_attributes][:address_line],
              phone: partner.phone,
              default_address: true,
            },
          )
          partner.save!
          response = ShopothWarehouse::V1::Entities::Partners.represent(partner)
          success_response_with_json('Successfully created partner.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create partner due to: #{error.message}"
          error!(failure_response_with_json('Unable to create partner.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc "Update a specific Partner's information."
        params do
          use :update_partner_params
        end
        put ':id' do
          if check_wh_warehouse
            error!(failure_response_with_json("Central warehouse can't update partner.",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          partner = Partner.find_by(id: params[:id])
          unless partner
            error!(failure_response_with_json('Partner not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          if params[:partner][:meta_datum_attributes].present?
            meta_datum_id = partner.meta_datum&.id
            params[:partner][:meta_datum_attributes] = params[:partner][:meta_datum_attributes].merge(id: meta_datum_id)
          end

          partner_params = validate_partner_update_params(partner, params)
          partner.update!(partner_params)
          if params[:address_attributes].present?
            create_or_update_address(partner, params[:address_attributes])
          end

          if params[:partner][:password].present? && params[:partner][:password] == params[:partner][:password_confirmation]
            partner.update!(
              password: params[:partner][:password],
              password_confirmation: params[:partner][:password_confirmation],
            )
          end

          partner.update!(image_file: params[:partner][:image_file]) if params[:partner][:image_file].present?

          response = ShopothWarehouse::V1::Entities::Partners.represent(partner)
          success_response_with_json("Successfully updated partner's information.", HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to update partner due to: #{error.message}"
          error!(failure_response_with_json('Unable to update partner.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Delete a Partner'
        route_param :id do
          delete do
            if check_wh_warehouse
              error!(respond_with_json('Not permitted to delete', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end
            partner = @current_staff.warehouse.partners.find_by(id: params[:id])
            unless partner.present?
              error!(respond_with_json('partner not found', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end
            if partner.customer_orders.present? || partner.partner_margins.present?
              error!(respond_with_json('This partner has customer orders, hence can not deleted',
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            respond_with_json('Successfully deleted', HTTP_CODE[:OK]) if partner.destroy!
          rescue StandardError => error
            Rails.logger.info "partner deletion failed #{error.message}"
            error!(respond_with_json('Unable to delete', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Partner Details'
        get '/:id/partner_details' do
          if @current_staff.warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:central]
            partner = Partner.find_by(id: params[:id])
          else
            partner = @current_staff.warehouse&.partners.find_by(id: params[:id])
          end
          if partner.present?
            present partner, with: ShopothWarehouse::V1::Entities::PartnerDetails
          else
            respond_with_json("Unable to find partner", HTTP_CODE[:NO_CONTENT])
          end
        rescue => ex
          error!("Unable to find partner due to #{ex.message}")
        end

        desc 'Customer orders of a specific partner.'
        params do
          use :customer_orders_of_a_specific_partner
        end

        get '/:id/customer_orders' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : (Date.today - 1.months).to_datetime.utc
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : Date.today.to_datetime.utc
          partner = if check_wh_warehouse
                      Partner.find_by(id: params[:id])
                    else
                      @current_staff.warehouse.partners.find_by(id: params[:id])
                    end

          unless partner
            Rails.logger.info 'Unable to find partner'
            error!(respond_with_json('Unable to find partner', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end
          order_status_ids = OrderStatus.where(order_type: %i(completed partially_returned)).pluck(:id)
          customer_orders = partner.customer_orders.
                            joins(:payments).
                            where('payments.created_at >= ? AND payments.created_at <= ? AND payments.paymentable_type = ? AND payments.receiver_type = ? AND customer_orders.order_status_id in (?)',
                                  start_date_time.to_date.beginning_of_day, end_date_time.to_date.end_of_day,
                                  'User', 'Partner', order_status_ids).distinct
          # TODO: Need to Optimize Query
          present paginate(Kaminari.paginate_array(customer_orders)), with: ShopothWarehouse::V1::Entities::PartnersCustomerOrder
        rescue StandardError => error
          Rails.logger.error "Unable to fetch customer orders due to #{error.message}"
          error!(respond_with_json('Unable to fetch customer orders', HTTP_CODE[:NOT_FOUND]),
                 HTTP_CODE[:NOT_FOUND])
        end

        get '/:id/order_summary' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : (Date.today - 1.months).to_datetime.utc
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : Date.today.to_datetime.utc

          if @current_staff.warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:central]
            partner = Partner.find_by(id: params[:id])
          else
            partner = @current_staff.warehouse&.partners.find_by(id: params[:id])
          end

          return_customer_orders = partner.return_customer_orders

          if start_date_time.present? && end_date_time.present?
            customer_orders = partner.customer_orders
            partner_customer_orders = customer_orders
                                        .joins(:payments)
                                        .where('payments.created_at >= ? AND payments.created_at <= ? AND payments.paymentable_type = ? AND payments.receiver_type = ? AND payments.receiver_type IS NOT null AND customer_orders.order_status_id = ?', start_date_time.to_date.beginning_of_day, end_date_time.to_date.end_of_day, 'User', 'Partner', OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]).id).distinct

            # sr_customer_orders = customer_orders
            #                        .joins(:payments)
            #                        .where('payments.created_at >= ? AND payments.created_at <= ? AND payments.paymentable_type = ? AND payments.receiver_type = ? AND payments.receiver_type IS NOT null AND customer_orders.order_status_id = ?',start_date_time.to_date.beginning_of_day, end_date_time.to_date.end_of_day, 'Partner', 'Route', OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]).id).distinct

            return_customer_orders = return_customer_orders.
                                     joins(:return_status_changes).
                                     where('return_status_changes.created_at >= ? AND return_status_changes.created_at <= ?', start_date_time.to_date.beginning_of_day, end_date_time.to_date.end_of_day).includes(:return_status_changes)

            sr_customer_orders = customer_orders.where(order_status_id: OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]).id)

            sr_customer_orders = sr_customer_orders.joins(customer_order_status_changes: :order_status).
                                 where('order_statuses.order_type IN (6) AND
                                customer_order_status_changes.created_at >= ? AND
                                customer_order_status_changes.created_at <= ?', start_date_time.to_date.beginning_of_day, end_date_time.to_date.end_of_day)

            total_unpack_sku = return_customer_orders.where('return_customer_orders.return_type = ?', ReturnCustomerOrder.return_types[:unpacked])
            collected_by_sr_unpacked = total_unpack_sku.where('return_status_changes.changeable_type = ?', 'Route')

            total_pack_sku = return_customer_orders.where('return_customer_orders.return_type = ?', ReturnCustomerOrder.return_types[:packed])
            collected_by_sr_packed = total_pack_sku.where('return_status_changes.changeable_type = ?', 'Route')
            total = 0
            partner_customer_orders.each do |customer_order|
              co = customer_order.payments.where('created_at >= ? AND created_at <= ? AND paymentable_type = ? AND receiver_type = ? AND receiver_type IS NOT null', start_date_time.to_date.beginning_of_day, end_date_time.to_date.end_of_day, 'User', 'Partner')
              total += co&.first&.currency_amount.present? ? co&.first&.currency_amount : 0
            end

            # sr_total = 0
            # sr_customer_orders.each do |customer_order|
            #   co = customer_order.payments.where('created_at >= ? AND created_at <= ? AND paymentable_type = ? AND receiver_type = ? AND receiver_type IS NOT null', start_date_time, end_date_time, 'Partner', 'Route')
            #   sr_total += co&.first&.currency_amount.present? ? co&.first&.currency_amount : 0
            # end

          end

          return_customer_orders_hash = {
            total_order: partner_customer_orders.count,
            total: total,
            collected_by_sr: collected_by_sr(sr_customer_orders),
            unpack_return: { no_of_skus: total_unpack_sku.count, collected_by_sr: collected_by_sr_unpacked.count },
            pack_return: { no_of_orders: total_pack_sku.count, collected_by_sr: collected_by_sr_packed.count },
          }
        rescue => ex
          error!("Unable to return customer orders due to #{ex.message}")
        end

        get '/:id/customer_orders_export' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : (Date.today - 1.months).to_datetime.utc
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : Date.today.to_datetime.utc
          if @current_staff.warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:central]
            partner = Partner.find_by(id: params[:id])
          else
            partner = @current_staff.warehouse&.partners.find_by(id: params[:id])
          end
          customer_orders = partner.customer_orders.
                            where(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])).
                            order(created_at: :desc)

          if start_date_time.present? && end_date_time.present?
            customer_orders = customer_orders.joins(:payments).where("payments.created_at >= ? AND payments.created_at <= ? AND payments.receiver_type=?", start_date_time.to_date.beginning_of_day, end_date_time.to_date.end_of_day, 'Partner').uniq
          end
          present customer_orders, with: ShopothWarehouse::V1::Entities::PartnersCustomerOrder
        rescue => ex
          error!("Unable to return customer orders due to #{ex.message}")
        end
      end
    end
  end
end
