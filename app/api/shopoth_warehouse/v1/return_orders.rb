module ShopothWarehouse
  module V1
    class ReturnOrders < ShopothWarehouse::Base
      helpers ShopothWarehouse::V1::Serializers::CustomerOrderSerializer
      helpers ShopothCustomerCare::V1::Serializers::ReturnOrderSerializer

      RETURN_STATUS = %w(initiated in_partner)
      helpers do
        def fetch_return_orders(partners)
          partners.map do |partner|
            next unless schedule_matched?(partner)

            partner.return_customer_orders
          end.flatten.compact
        end

        def fetch_individual_return_orders(partner_id)
          partner = @current_route_device.route.partners.find(partner_id)
          return [] unless schedule_matched?(partner)

          partner.return_customer_orders
        end

        def schedule_matched?(partner)
          partner_schedule = partner.schedule
          current_day = Date.today.strftime("%A")[0..2].downcase
          partner_schedule.include?(current_day)
        end

        def collected_today?(order)
          order.return_status == 'in_transit' &&
            (Date.today.beginning_of_day..Date.today.end_of_day).include?(order.delivered_to_sr_at)
        end

        def deductible_amount(return_order)
          line_item = return_order.shopoth_line_item
          price = (line_item&.sub_total / (line_item&.quantity || 1)) || 0
          price * 0.05 * (return_order&.quantity || 1)
        end

        def deduct_partner_margin(customer_order, return_order)
          partner_margin = customer_order.partner_margin.margin_amount
          if customer_order.induced?
            partner_margin -= deductible_amount(return_order)
            partner_margin = partner_margin.negative? ? 0 : partner_margin
            customer_order.partner_margin.update!(margin_amount: partner_margin.round(2))
          elsif customer_order.organic? && customer_order.return_all_unpacked_items?
            partner_margin -= 15
            customer_order.partner_margin.update!(margin_amount: partner_margin)
          end
        end
      end

      resource :return_orders do
        desc 'create a return order'
        params do
          requires :return_order, type: Hash do
            requires :customer_order_id, type: Integer
            requires :partner_id, type: Integer
            requires :reason, type: String, values: %w(defected_product date_expired disagreed_product)
          end
        end

        route_setting :authentication, optional: true
        post do
          return_order_params = params[:return_order]
          return_order = ReturnCustomerOrder.new(return_order_params)
          if return_order.save!
            status :ok
            return_order
          end
        rescue => ex
          status :unprocessable_entity
          error! respond_with_json("Unable to create return order due to #{ex.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get return order list for SR.'
        params do
          optional :partner_id, type: Integer
        end

        route_setting :authentication, type: RouteDevice
        get 'get_return_list' do
          partner_id = params[:partner_id]
          return_orders = if partner_id.present?
                            fetch_individual_return_orders(partner_id).select do |order|
                              order.return_status == 'in_partner' || collected_today?(order)
                            end
                          else
                            fetch_return_orders(@current_route_device.route&.partners).select do |order|
                              RETURN_STATUS.include?(order.return_status.to_s) || collected_today?(order)
                            end
                          end
          status :ok
          return [] unless return_orders.present?

          present return_orders.sort, with: ShopothWarehouse::V1::Entities::ReturnOrders
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch return_order list due to: #{error.message}"
          error! respond_with_json('Unable to fetch return_order list.', HTTP_CODE[:NOT_FOUND])
        end

        route_setting :authentication, type: RouteDevice
        get 'get_return_list_history' do
          partner_id = params[:partner_id]
          return_orders = if partner_id.present?
                            fetch_individual_return_orders(partner_id).select do |order|
                              order.return_status == 'in_transit'
                            end
                          else
                            partners = @current_route_device.route&.partners
                            fetch_return_orders(partners).select do |order|
                              order.return_status == 'in_transit'
                            end
                          end
          status :ok
          return [] unless return_orders.present?

          present return_orders, with: ShopothWarehouse::V1::Entities::ReturnOrders
        rescue => ex
          error! respond_with_json("Unable to fetch return list due to #{ex.message}",
                                   HTTP_CODE[:NOT_FOUND])
        end

        desc 'Collect Returns From Partner.'
        params do
          requires :return_id, type: Integer
          requires :qr_code, type: String
        end
        route_setting :authentication, type: RouteDevice
        put '/collect' do
          return_order = ReturnCustomerOrder.in_partner.find(params[:return_id])
          customer_order = return_order&.customer_order
          if return_order.in_partner? &&
             ((return_order.packed? && customer_order&.id == params[:qr_code].to_i) ||
             (return_order.unpacked? && return_order.shopoth_line_item.qr_codes[0] == params[:qr_code]))

            ActiveRecord::Base.transaction do
              return_order.update!(return_status: :in_transit, delivered_to_sr_at: Time.now,
                                   changeable: @current_route_device.route)
              if return_order.packed?
                return_order.update_inventory_and_stock_changes('return_in_transit_quantity', 'return_in_partner_quantity')
              else
                return_order.update_inventory_and_stock_changes('return_in_transit_quantity', nil)
              end

              if customer_order.pick_up_point? && return_order.unpacked?
                aggr_return = return_order.aggregate_return
                deduct_partner_margin(customer_order, return_order)
                customer_order.distributor_margin.deduct(return_order.shopoth_line_item)
                if aggr_return.return_customer_orders.where(return_status: %i(in_partner initiated)).count.zero?
                  return_order.calculate_coupon_amount
                end
              end
            end
            status :ok
            respond_with_json('Success', HTTP_CODE[:OK])
          else
            status :not_found
            error! respond_with_json('Wrong return code scanned!', HTTP_CODE[:NOT_ACCEPTABLE])
          end
        rescue => error
          Rails.logger.info("failed due to #{error.full_message}")
          error! respond_with_json("failed : #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get return_order list for a specific warehouse.'
        params do
          use :pagination, per_page: 50
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : nil
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : nil

          return_orders = check_dh_warehouse ? @current_staff.warehouse.return_customer_orders.packed : ReturnCustomerOrder.packed

          return_orders = params[:order_id].present? ? return_orders.where(customer_order_id: params[:order_id]) : return_orders

          return_orders = params[:distributor_id].present? ? return_orders.where(distributor_id: params[:distributor_id]) : return_orders

          return [] unless return_orders.present?

          if start_date_time.present? && end_date_time.present?
            return_orders = return_orders.where(created_at: start_date_time.to_date.beginning_of_day..end_date_time.to_date.end_of_day)
          end
          if return_orders.present?
            # TODO: Need to Optimize Query
            present paginate(Kaminari.paginate_array(return_orders.order(created_at: :desc))), with: ShopothWarehouse::V1::Entities::ReturnOrderLists::List
          else
            []
          end
        rescue => error
          error! respond_with_json("Unable to fetch return_order list due to #{error.message}", HTTP_CODE[:NOT_FOUND])
        end

        desc 'Unpack packed_returned_orders for Route/Rider.'
        get '/unpack/:id' do
          return_order = @current_staff.warehouse&.return_customer_orders&.find(params[:id])
          if return_order.packed? && return_order.relocation_pending?
            present return_order, with: ShopothWarehouse::V1::Entities::ReturnOrderDetailsWithLineItems
          else
            error!(respond_with_json('Return Order is not packed or qc failed.',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError => error
          error!(respond_with_json("Unable to unpack return order due to #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get a specific return_order details.'
        route_param :id do
          get do
            return_order = ReturnCustomerOrder.find(params[:id])
            return_details_customer(return_order)
            # present return_order, with: ShopothWarehouse::V1::Entities::ReturnOrderLists::ReturnDetails
          rescue => error
            error! respond_with_json("Unable to show due to #{error}", HTTP_CODE[:NOT_FOUND])
          end
        end

        desc 'Assigning riders to return_order by DH admin.'
        params do
          requires :rider_id, type: Integer
        end

        route_param :id do
          post 'assign_rider' do
            return_order = ReturnCustomerOrder.find(params[:id])
            rider = return_order.customer_order.distributor.riders.find(params[:rider_id])
            return_order.update!(rider_id: rider.id) unless rider.blank?
            respond_with_json('Successfully assigned rider.', HTTP_CODE[:OK])
          rescue => error
            error! respond_with_json("Unable to update due to #{error}", HTTP_CODE[:NOT_FOUND])
          end
        end
      end
    end
  end
end
