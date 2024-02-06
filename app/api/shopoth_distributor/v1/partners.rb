module ShopothDistributor
  module V1
    class Partners < ShopothDistributor::Base
      resource :partners do
        desc 'Get all partners on DH panel.'
        params do
          use :pagination, per_page: 50
          optional :skip_pagination, type: Boolean
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_month : Time.now.utc.beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.utc.end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
            error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          status = OrderStatus.find_by(order_type: params[:status]) if params[:status] == 'completed'
          partners = params[:phone].present? ? @current_distributor.partners.where('partners.phone = ?', params[:phone]) : @current_distributor.partners
          partners = params[:route_id].present? ? partners.where('partners.route_id = ?', params[:route_id]) : partners
          partners = params[:partner_code].present? ? partners.where('partners.partner_code = ?', params[:partner_code]) : partners
          partners = paginate(Kaminari.paginate_array(partners)) unless params[:skip_pagination]

          response = partners&.map do |partner|
            customer_orders = partner.customer_orders.joins(customer_order_status_changes: :order_status).where(
              'customer_orders.order_status_id IN (7, 8)',
            ).where('order_statuses.order_type IN (6) AND (customer_order_status_changes.created_at BETWEEN ? AND ?)', start_date_time, end_date_time)
            customer_orders = customer_orders.where(status: status) if status
            return_orders = partner.return_customer_orders.where(
              'return_customer_orders.return_status IN (0, 1) AND return_customer_orders.created_at BETWEEN ? AND ?', start_date_time, end_date_time
            )
            unless status
              return_customer_order_ids = ReturnCustomerOrder.packed.where('customer_order_id in (?)', customer_orders.ids).pluck(:customer_order_id)
              customer_orders = customer_orders.where('customer_orders.id NOT IN (?)', return_customer_order_ids) if return_customer_order_ids.present?
            end
            fetch_customer_orders(partner, customer_orders, return_orders)
          end
          success_response_with_json('Successfully fetched partners.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch partners due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch partners.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        route_param :id do
          before do
            @partner ||= @current_distributor.partners.find_by(id: params[:id])
            unless @partner
              error!(failure_response_with_json('Unable to find partner.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end
          end

          desc 'Get a specific partner details on DH panel.'
          get do
            success_response_with_json('Successfully fetched partner details.', HTTP_CODE[:OK],
                                       ShopothWarehouse::V1::Entities::Partners.represent(@partner))
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch partner details due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch partner details.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc "Get partner's completed orders on DH panel."
          params do
            requires :month, type: Integer
            requires :year, type: Integer
          end
          get '/completed_orders' do
            start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
            end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
            statuses = OrderStatus.fetch_statuses(%w(completed partially_returned))
            customer_orders = @partner.customer_orders.where(status: statuses, completed_at: start_date..end_date).includes(:partner_margin, :status)
            response = ShopothWarehouse::V1::Entities::CustomerOrderWithMargin.represent(customer_orders)
            success_response_with_json('Successfully fetched completed orders.', HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to fetch completed orders due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch completed orders.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          desc 'Customer orders of a specific partner on DH panel.'
          params do
            optional :start_date_time, type: DateTime
            optional :end_date_time, type: DateTime
            optional :skip_pagination, type: Boolean
            use :pagination, per_page: 50
          end
          get '/customer_orders' do
            start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
            end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
            unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
              error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            date_range = start_date_time..end_date_time
            order_status_ids = OrderStatus.where(order_type: %i(completed partially_returned)).pluck(:id)
            customer_orders = @partner.customer_orders.joins(:payments).where(
              payments: { created_at: date_range, paymentable_type: 'User', receiver_type: 'Partner' }, order_status_id: order_status_ids,
            )

            customer_orders = if params[:skip_pagination]
                                customer_orders
                              else
                                paginate(Kaminari.paginate_array(customer_orders))
                              end

            response = ShopothWarehouse::V1::Entities::PartnersCustomerOrder.represent(customer_orders)
            success_response_with_json('Successfully fetched customer orders.', HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "Unable to fetch customer orders due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch customer orders.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY], []), HTTP_CODE[:OK])
          end

          desc 'Customer orders summary of a specific partner on DH panel.'
          get '/order_summary' do
            start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
            end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month
            unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
              error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            date_range = start_date_time..end_date_time
            status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
            customer_orders = @partner.customer_orders
            partner_customer_orders = customer_orders&.joins(:payments)&.where(
              payments: { status: :successful, created_at: date_range, paymentable_type: 'User', receiver_type: 'Partner' }, order_status_id: status.id,
            )
            sr_customer_orders = customer_orders&.where(order_status_id: status.id)&.joins(customer_order_status_changes: :order_status)&.where(
              customer_order_status_changes: { created_at: date_range },
            )&.where('order_statuses.order_type IN (6)')
            collected_by_sr = sr_customer_orders.joins(:payments).where(
              payments: { status: :successful, paymentable_type: 'Partner', receiver_type: 'Route' },
            ).sum(:currency_amount) || 0
            total = partner_customer_orders&.joins(:payments)&.where(
              payments: { status: :successful, created_at: date_range, paymentable_type: 'User', receiver_type: 'Partner' },
            )&.sum(:currency_amount) || 0

            return_customer_orders = @partner.return_customer_orders&.joins(:return_status_changes)&.where(return_status_changes: { created_at: date_range })
            total_unpack_sku = return_customer_orders&.where(return_type: ReturnCustomerOrder.return_types[:unpacked])
            collected_by_sr_unpacked = total_unpack_sku&.where("return_status_changes.changeable_type = 'Route'")
            total_pack_sku = return_customer_orders&.where(return_type: ReturnCustomerOrder.return_types[:packed])
            collected_by_sr_packed = total_pack_sku&.where("return_status_changes.changeable_type = 'Route'")

            response = {
              total: total,
              collected_by_sr: collected_by_sr,
              total_order: partner_customer_orders.size || 0,
              unpack_return: { no_of_skus: total_unpack_sku.size || 0, collected_by_sr: collected_by_sr_unpacked.size || 0 },
              pack_return: { no_of_orders: total_pack_sku.size || 0, collected_by_sr: collected_by_sr_packed.size || 0 },
            }
            success_response_with_json('Successfully fetched customer orders summary.', HTTP_CODE[:OK], response)
          rescue StandardError => error
            Rails.logger.error "Unable to fetch customer orders summary due to: #{error.message}"
            error!(failure_response_with_json('Unable to fetch customer orders summary.',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY], []), HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
