# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class CustomerOrderList < ShopothWarehouse::Base
      helpers do
        def find_or_create_warehouse_variant_locations(warehouse_variant, passed_quantity, location_id)
          warehouse_variants_location = warehouse_variant.warehouse_variants_locations.find_or_create_by!(location_id: location_id)
          quantity = if warehouse_variants_location.quantity
                       warehouse_variants_location.quantity + passed_quantity
                     else
                       passed_quantity
                     end
          warehouse_variants_location.update!(quantity: quantity)
        end

        def order_case_sql
          <<~SQL
            CASE
              WHEN shipping_type = 1 AND order_status_id = 1 THEN 1
              WHEN shipping_type = 1 AND order_status_id = 2 THEN 2
              WHEN shipping_type = 1 AND order_status_id = 3 THEN 3
              WHEN shipping_type = 1 AND order_status_id = 4 THEN 4
              WHEN shipping_type = 1 AND order_status_id = 5 THEN 5
              WHEN shipping_type = 1 AND order_status_id = 6 THEN 6
              WHEN shipping_type = 1 AND order_status_id = 7 THEN 7
              WHEN shipping_type = 0 AND order_status_id = 1 THEN 8
              WHEN shipping_type = 0 AND order_status_id = 2 THEN 9
              WHEN shipping_type = 0 AND order_status_id = 3 THEN 10
              WHEN shipping_type = 0 AND order_status_id = 4 THEN 11
              WHEN shipping_type = 0 AND order_status_id = 5 THEN 12
              WHEN shipping_type = 0 AND order_status_id = 6 THEN 13
              WHEN shipping_type = 0 AND order_status_id = 7 THEN 14
              WHEN shipping_type = 2 AND order_status_id = 1 THEN 15
              WHEN shipping_type = 2 AND order_status_id = 2 THEN 16
              WHEN shipping_type = 2 AND order_status_id = 3 THEN 17
              WHEN shipping_type = 2 AND order_status_id = 4 THEN 18
              WHEN shipping_type = 2 AND order_status_id = 5 THEN 19
              WHEN shipping_type = 2 AND order_status_id = 6 THEN 20
              WHEN shipping_type = 2 AND order_status_id = 7 THEN 21
              ELSE 22
            END,
            created_at DESC
          SQL
        end

        def sku_checking(packed_items)
          packed_items.each do |packed_item|
            line_item = ShopothLineItem.find(packed_item[:line_item_id])
            codes = packed_item[:qr_codes]
            variant_sku = line_item&.variant&.sku
            error!('QR Code is mismatch or blank!', HTTP_CODE[:NOT_FOUND]) unless codes.all?(variant_sku)
          end
        end

        def validate_quantity(customer_order, packed_items)
          item_ids = packed_items.pluck(:line_item_id).uniq
          shopoth_items = customer_order.shopoth_line_items
          return false unless item_ids == shopoth_items.pluck(:id)

          items_total_quantity = {}
          packed_items.each do |item|
            if items_total_quantity.key?(item[:line_item_id]).present?
              items_total_quantity[item[:line_item_id]] += item[:quantity]
            else
              items_total_quantity[item[:line_item_id]] = item[:quantity]
            end
          end
          item_ids.each do |item_id|
            line_item_quantity = shopoth_items.find_by(id: item_id).quantity
            return false unless items_total_quantity[item_id] == line_item_quantity
          end
          true
        end

        def location_quantity_available?(customer_order, packed_items)
          packed_items.each do |packed_item|
            location = @current_staff.warehouse.locations.find_by(id: packed_item[:location_id])
            return false unless location.present?

            line_item = customer_order.shopoth_line_items.find_by(id: packed_item[:line_item_id])
            return false unless line_item

            # create line_item_locations to validate location
            line_item_location = LineItemLocation.create!(location_id: location.id,
                                                          shopoth_line_item_id: line_item.id,
                                                          quantity: packed_item[:quantity],
                                                          qr_codes: packed_item[:qr_codes])
            warehouse_variant = @current_staff.warehouse.warehouse_variants.find_by(variant: line_item.variant)
            warehouse_variant_location = warehouse_variant.warehouse_variants_locations.
                                         where('quantity > 0').find_by(location: location)
            return false if warehouse_variant_location&.quantity < line_item_location.quantity
          end
          true
        end

        def warehouse_variant_location_update(customer_order, packed_items)
          sku_checking(packed_items)
          ActiveRecord::Base.transaction do
            items = []
            packed_items.each do |packed_item|
              line_item = customer_order.shopoth_line_items.find_by(id: packed_item[:line_item_id])
              line_item_location = line_item.line_item_locations.find_by(location_id: packed_item[:location_id])
              items << { variant_id: line_item.variant.id, quantity: line_item_location.quantity, customer_order: customer_order }
              qr_codes = packed_item[:qr_codes]
              warehouse_variant = @current_staff.warehouse.warehouse_variants.find_by(variant: line_item.variant)
              location = @current_staff.warehouse.locations.find(packed_item[:location_id])
              unless location.present?
                error!(respond_with_json('Location not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
              end
              line_item.update(qr_codes: qr_codes)
              warehouse_variant_location = warehouse_variant.warehouse_variants_locations.find_by(location: location)
              if (warehouse_variant_location.quantity - line_item_location.quantity).negative?
                Rails.logger.error "\nWarehouse_variant_location quantity is being negative for warehouse_variant_id: #{warehouse_variant.id} and Location_id: #{location.id}\n"
              end
              if (warehouse_variant.booked_quantity - line_item_location.quantity).negative?
                Rails.logger.error "\nBooked_quantity is being negative for sku = #{line_item.variant.sku}and
warehouse_variant_id: #{warehouse_variant.id}.Action: Customer Order Pack and Line_Item_id: #{line_item.id}\n"
              end
              warehouse_variant_location.update!(quantity: warehouse_variant_location.quantity - line_item_location.quantity)
            end
            wh_variants = WarehouseVariant.wh_variant_multi_location(items, @current_staff.warehouse.id)
            wh_variants.each do |wh_v|
              wh_v['wv_id'].update!(booked_quantity: wh_v['wv_id'].booked_quantity - wh_v['qty'],
                ready_to_ship_from_fc_quantity: wh_v['wv_id'].ready_to_ship_from_fc_quantity + wh_v['qty'])
              wh_v['wv_id'].save_stock_change('ready_to_ship_from_fc', wh_v['qty'], wh_v['stock_changeable'],
                                              'booked_quantity_change', 'ready_to_ship_from_fc_quantity_change')
            end
          end
        end
      end

      namespace :customer_orders do
        params do
          use :pagination, per_page: 50
          optional :business_type, type: String, values: CustomerOrder.business_types.keys
        end
        desc 'Show All Customer All Orders.'
        get '/list' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.at_beginning_of_day : Time.now.utc.at_beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.utc.at_end_of_day
          date_range = start_date_time..end_date_time
          all_orders = check_dh_warehouse ? @current_staff.warehouse.customer_orders.where(created_at: date_range) : CustomerOrder.where(created_at: date_range)
          return [] unless all_orders.present?

          all_orders = all_orders.where(business_type: params[:business_type]) if params[:business_type].present?
          all_orders = all_orders.where(warehouse_id: params[:warehouse_id]) if params[:warehouse_id].present?
          all_orders = all_orders.where(distributor_id: params[:distributor_id]) if params[:distributor_id].present?
          all_orders = all_orders.where(id: params[:order_no]) if params[:order_no].present?
          all_orders = all_orders.where(shipping_type: params[:shipping_type]) if params[:shipping_type].present?
          all_orders = all_orders.joins(:partner).where(partners: { schedule: params[:schedule] }) if params[:schedule].present?
          all_orders = all_orders.joins(:status).where("LOWER(order_statuses.admin_order_status) = ?", params[:status].downcase) if params[:status].present?
          # TODO: Need to Optimize Query
          if all_orders.present?
            present paginate(Kaminari.paginate_array(all_orders.order(order_case_sql))), with: ShopothWarehouse::V1::Entities::CustomerOrderList
          else
            []
          end
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Reconciled customer order list for Distribution warehouse.'
        params do
          use :pagination, per_page: 50
        end
        get '/reconciled' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
            return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
          end

          date_range = start_date_time..end_date_time
          customer_order_ids = @current_staff.warehouse.customer_orders.joins(:payments).where(
            "(payments.paymentable_type = 'Route' OR payments.paymentable_type = 'Rider') AND payments.receiver_type = 'Staff'",
          ).where(payments: { created_at: date_range }).distinct.ids
          customer_orders = CustomerOrder.where(id: customer_order_ids)
          # TODO: Need to Optimize Query
          order_response = ShopothWarehouse::V1::Entities::ReconciledOrders.represent(
            paginate(Kaminari.paginate_array(customer_orders.sort)),
          )
          total_collected_amount = customer_orders.joins(:payments).where(
            "(payments.paymentable_type = 'Route' OR payments.paymentable_type = 'Rider') AND payments.receiver_type = 'Staff'",
          ).sum('payments.currency_amount')

          total_deposited_amount = 0.0
          customer_orders.includes(:aggregated_transaction_customer_orders).distinct.each do |order|
            next unless order.aggregated_transaction_customer_orders.customer_payment.present?

            total_deposited_amount += order.payments.where("(paymentable_type = 'Route' OR paymentable_type = 'Rider') AND receiver_type = 'Staff'").sum(:currency_amount)
          end

          {
            total_collected_amount: total_collected_amount,
            total_deposited_amount: total_deposited_amount,
            due_amount: total_collected_amount - total_deposited_amount,
            orders: order_response,
          }
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch customer order list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch customer order list.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Show Details of a specific Order.'
        get ':id' do
          customer_order = if check_wh_warehouse
                             CustomerOrder.find_by(id: params[:id])
                           else
                             @current_staff.warehouse.customer_orders.find_by(id: params[:id])
                           end

          unless customer_order
            Rails.logger.info 'Unable to find customer order.'
            error!(respond_with_json('Unable to find customer order.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          present customer_order, with: ShopothWarehouse::V1::Entities::CustomerOrderDetails
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to show customer order details. Reason: #{error.message}"
          error!(respond_with_json("Can't show customer order details. Reason: #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        params do
          requires :packed_items, type: Array do
            requires :line_item_id, type: Integer
            requires :qr_codes, type: Array
            optional :location_id, type: Integer
            requires :quantity, type: Integer
          end
          optional :rider_id, type: Integer
        end

        desc 'CustomerOrder pack.'
        route_param :id do
          put 'pack' do
            customer_order = @current_staff.warehouse.customer_orders.find_by(id: params[:id])
            unless customer_order
              error!(respond_with_json('Customer order not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:OK])
            end

            if customer_order.is_customer_paid == false && !customer_order.cash_on_delivery?
              error!(respond_with_json('Only successful online payment should pack',
                                       HTTP_CODE[:PAYMENT_REQUIRED]), HTTP_CODE[:OK])
            end
            statuses = OrderStatus.fetch_statuses(%w(order_placed order_confirmed)).pluck(:id)
            unless statuses.include?(customer_order.status.id)
              error!(respond_with_json("This order can't be packed.", HTTP_CODE[:NOT_ACCEPTABLE]),
                     HTTP_CODE[:OK])
            end
            total_quantity_check = validate_quantity(customer_order, params[:packed_items])
            unless total_quantity_check
              error!(respond_with_json('Unable to pack due to mismatched quantity',
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end
            validity = location_quantity_available?(customer_order, params[:packed_items])
            if validity == false
              error!(respond_with_json('Unable to pack due to unavailable quantity.',
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
            end

            warehouse_variant_location_update(customer_order, params[:packed_items])
            customer_order.update!(
              status: OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_ship_from_fc]),
              changed_by: @current_staff,
            )
            ShopothWarehouse::V1::Entities::CustomerOrderDetails.represent(customer_order)
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nUnable to Pack order due to: #{error.message}"
            error!(respond_with_json('Unable to Pack order.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:OK])
          end
        end

        desc 'Assign rider to customer order.'
        route_param :id do
          put 'assign_rider' do
            if @current_warehouse.warehouse_type == Warehouse::WAREHOUSE_TYPES[:member]
              error!(respond_with_json('Rider can not be assigned for this order',
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end

            customer_order = @current_warehouse.customer_orders.find_by(id: params[:id])
            unless customer_order&.home_delivery? || customer_order&.express_delivery?
              error!(respond_with_json('Order not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end

            rider = customer_order.distributor&.riders&.find_by(id: params[:rider_id])
            unless rider
              error!(respond_with_json('Rider not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end

            statuses = OrderStatus.fetch_statuses(%w(ready_to_ship_from_fc in_transit_to_dh ready_to_shipment))
            unless statuses.include?(customer_order.status)
              error!(respond_with_json("Rider can't be assigned to this order.", HTTP_CODE[:NOT_ACCEPTABLE]),
                     HTTP_CODE[:NOT_ACCEPTABLE])
            end

            customer_order.update!(rider_id: rider.id)
            respond_with_json('Rider assigned successfully.', HTTP_CODE[:OK])
          rescue => ex
            error! respond_with_json "Unable to Assign Rider because #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]
          end
        end

        desc 'Cancel Customer order from Warehouse.'
        route_param :id do
          put 'cancel_order' do
            customer_order = @current_staff.warehouse.customer_orders.find_by(id: params[:id])

            unless customer_order
              error!(respond_with_json('Customer Order not found.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end

            statuses = %w(delivered_to_partner completed cancelled sold_to_partner
                          in_transit_cancelled packed_cancelled returned_from_customer
                          partially_returned returned_from_partner cancelled_at_dh
                          cancelled_at_in_transit_to_dh)
            if statuses.include?(customer_order&.status&.order_type)
              error!(respond_with_json("This order can't be cancelled.", HTTP_CODE[:NOT_ACCEPTABLE]),
                     HTTP_CODE[:NOT_ACCEPTABLE])
            else
              cancelled_status = if customer_order.status.in_transit? || customer_order.status.on_hold? || customer_order.status.in_transit_partner_switch? || customer_order.status.in_transit_delivery_switch? || customer_order.status.in_transit_reschedule?
                                   OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_cancelled])
                                 elsif customer_order.status.ready_to_ship_from_fc?
                                   OrderStatus.getOrderStatus(OrderStatus.order_types[:packed_cancelled])
                                 elsif customer_order.status.ready_to_shipment?
                                   OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled_at_dh])
                                 elsif customer_order.status.order_placed? || customer_order.status.order_confirmed?
                                   OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled])
                                 elsif customer_order.status.in_transit_to_dh?
                                   OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled_at_in_transit_to_dh])
                                 end
              customer_order.update!(status: cancelled_status, cancellation_reason: params[:cancellation_reason],
                                     changed_by: @current_staff)
              status :ok
              respond_with_json('Order Canceled!', HTTP_CODE[:OK])
            end
          rescue => ex
            error! respond_with_json "Unable to Canceled order because #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]
          end
        end

        desc 'unpack pack cancelled order'
        route_param :id do
          put 'unpack' do
            customer_order = @current_staff.warehouse.customer_orders.find(params[:id])
            status = OrderStatus.getOrderStatus(OrderStatus.order_types[:packed_cancelled])
            warehouse = @current_staff.warehouse
            if customer_order.present? && customer_order.status == status
              shopoth_line_items = customer_order.shopoth_line_items
              if shopoth_line_items.count == params[:variants_locations].count
                params[:variants_locations].each do |vl|
                  shopoth_line_item = shopoth_line_items.find_by(variant_id: vl[:variant_id])
                  available_quantity = shopoth_line_item.quantity
                  warehouse_variant = warehouse.warehouse_variants.find_by(variant_id: vl[:variant_id])
                  if warehouse_variant.present?
                    find_or_create_warehouse_variant_locations(warehouse_variant, available_quantity, vl[:location_id])
                  end
                end
                cancelled_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled])
                customer_order.update!(order_status_id: cancelled_status.id, changed_by: @current_staff)
                respond_with_json('Success Order Cancelled!', HTTP_CODE[:OK])
              else
                respond_with_json('Variant quantity mismatch!', HTTP_CODE[:NOT_FOUND])
              end
            else
              respond_with_json('Customer Order not found!', HTTP_CODE[:NOT_FOUND])
            end
          rescue => ex
            error! respond_with_json "Unable to Unpacked order because #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]
          end
        end

        desc 'Customer Order Status Changes Detail'
        get ':id/changes_log' do
          customer_order = if check_wh_warehouse
                             CustomerOrder.find_by(id: params[:id])
                           else
                             @current_staff.warehouse.customer_orders.find_by(id: params[:id])
                           end

          unless customer_order
            Rails.logger.info 'Unable to find customer order.'
            error!(respond_with_json('Unable to find customer order.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
          changes_log = customer_order.customer_order_status_changes
          success_response_with_json('Successfully fetched customer order changes log', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::CustomerOrderStatusChange.represent(changes_log))
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to fetch customer order changes log due to, #{error.message}"
          error!(respond_with_json("Unable to fetch customer order changes log due to, #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
