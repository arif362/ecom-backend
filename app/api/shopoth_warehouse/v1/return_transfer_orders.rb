# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class ReturnTransferOrders < ShopothWarehouse::Base
      helpers do
        def check_if_quantity_positive(params)
          params[:return_transfer_order_params].each do |item|
            variant = Variant.find_by(id: item[:variant_id])
            unless variant
              error!(failure_response_with_json("Couldn't find variant for id #{item[:variant_id]}.",
                                                HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
            end

            quantity = item[:quantity]
            unless quantity.positive?
              error!(failure_response_with_json("Please give positive quantity for variant #{variant.sku}.",
                                                HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
            end
          end
        end

        def create_transfer_order(warehouse, order_params)
          return_order = nil
          ActiveRecord::Base.transaction do
            return_order = ReturnTransferOrder.create!(
              warehouse: warehouse,
            )
            total_price = 0
            order_params.each do |item|
              variant = Variant.find_by(id: item[:variant_id])
              return_order.create_line_item(variant, item[:quantity])
              total_price += (variant.price_distribution.to_d * item[:quantity])
            end
            return_order.update!(
              quantity: return_order.line_items.sum(&:quantity),
              total_price: total_price,
              created_by_id: @current_staff.id,
            )
          end
          return_order
        end

        def check_box_item(box_id, line_item_id)
          box_item = BoxLineItem.find_by(box_id: box_id, line_item_id: line_item_id)
          if box_item.present?
            box_item
          else
            status :not_found
            return respond_with_json 'Unable to delete. reason: requested line item has no box'
          end
        end

        def item_quantity_available?(items, transfer_order, warehouse)
          items.each do |item|
            quantity = item[:quantity]
            line_item = transfer_order.line_items.find_by(id: item[:line_item_id])
            unless line_item.variant.sku == item[:sku]
              error!(failure_response_with_json("Unable to pack. reason: need to give line_item's all quantity.",
                                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end

            warehouse_variant = line_item.variant.warehouse_variants.find_by(warehouse: warehouse)
            wv_location = warehouse_variant.warehouse_variants_locations.find_by(location_id: item[:location_id])
            unless quantity <= warehouse_variant.available_quantity && quantity <= wv_location.quantity && !(warehouse_variant.available_quantity - quantity).negative?
              error!(respond_with_json("Quantity isn't available for sku: #{line_item.variant.sku}.",
                                       HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end
        end

        # def rto_variants_location_update(line_items, rt_order)
        #   updated_quantity_count = 0
        #   ActiveRecord::Base.transaction do
        #     line_items.each do |line_item|
        #       quantity = line_item[:quantity]
        #       raise ActiveRecord::Rollback, "Unable to pack. reason: quantity can't be  negative" unless quantity.positive?
        #       # unless quantity.positive?
        #       #   error!(respond_with_json("Unable to pack. reason: quantity can't be  negative",
        #       #                            HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
        #       # end
        #
        #       sku = line_item[:sku]
        #       warehouse = @current_staff.warehouse
        #       item = rt_order.line_items.find(line_item[:line_item_id])
        #
        #       raise ActiveRecord::Rollback, "Unable to pack. reason: need to give all quantity"  unless item.quantity == quantity
        #       #   error!(respond_with_json("Unable to pack. reason: need to give all quantity",
        #       #                            HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
        #       # end
        #
        #       warehouse_variant = item.variant.warehouse_variants.find_by(warehouse: warehouse)
        #       warehouse_variants_location = warehouse_variant.warehouse_variants_locations.find_by(location_id: line_item[:location_id])
        #
        #       if quantity <= warehouse_variants_location.quantity && item.variant.sku == sku
        #         warehouse_variants_location.update(quantity: (warehouse_variants_location.quantity - quantity))
        #         item.update(qr_code: sku, send_quantity: quantity)
        #         updated_quantity_count += 1
        #       else
        #         raise ActiveRecord::Rollback
        #       end
        #     end
        #   rescue => error
        #     error!(respond_with_json(error.message,
        #                                HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:NOT_ACCEPTABLE])
        #   end
        #   line_items.count == updated_quantity_count
        # end
      end

      resource :return_transfer_orders do
        desc 'Get all ReturnTransferOrders.'
        params do
          use :pagination, per_page: 50
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
          optional :rto_no, type: String
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
            error!(respond_with_json("The selected date range (start_date: #{start_date_time} and end_date:
                                     #{end_date_time}) is not valid! Please select a  range within 3 months.",
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          date_range = start_date_time..end_date_time
          transfer_orders = if check_wh_warehouse
                              ReturnTransferOrder.where(created_at: date_range).includes(:warehouse)
                            else
                              @current_staff.warehouse.return_transfer_orders.where(created_at: date_range).includes(:warehouse)
                            end

          transfer_orders = transfer_orders.where(id: params[:rto_no]&.to_i) if params[:rto_no].present?
          # TODO: Need to Optimize Query
          response = ShopothWarehouse::V1::Entities::TransferOrderList.represent(paginate(Kaminari.paginate_array(transfer_orders)))
          success_response_with_json('Successfully fetched return transfer orders.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch return transfer orders due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch return transfer orders.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get all ReturnTransferOrders for exporting.'
        params do
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
          optional :rto_no, type: String
        end
        get '/export' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= (3.month + 1.day)
            error!(respond_with_json("The selected date range (start_date: #{start_date_time} and end_date:
                                     #{end_date_time}) is not valid! Please select a  range within 3 months.",
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          date_range = start_date_time..end_date_time
          transfer_orders = if check_wh_warehouse
                              ReturnTransferOrder.where(created_at: date_range).includes(:warehouse)
                            else
                              @current_staff.warehouse.return_transfer_orders.where(created_at: date_range).includes(:warehouse)
                            end

          transfer_orders = transfer_orders.where(id: params[:rto_no]&.to_i) if params[:rto_no].present?
          ShopothWarehouse::V1::Entities::TransferOrderList.represent(transfer_orders)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch return transfer orders due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch return transfer orders.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Get details of a specific ReturnTransferOrder.'
        get ':id' do
          transfer_order = if check_wh_warehouse
                             ReturnTransferOrder.find_by(id: params[:id])
                           else
                             @current_staff.warehouse.return_transfer_orders.find_by(id: params[:id])
                           end

          unless transfer_order
            error!(failure_response_with_json('Unable to fetch return transfer orders',
                                              HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
          end

          response = ShopothWarehouse::V1::Entities::TransferOrderDetails.represent(
            transfer_order, warehouse: @current_staff.warehouse
          )
          success_response_with_json('Successfully fetched return transfer orders.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch return transfer orders due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch return transfer orders',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Create a return transfer order.'
        params do
          requires :return_transfer_order_params, type: Array do
            requires :variant_id, type: Integer
            requires :quantity, type: Integer
          end
        end
        post do
          check_if_quantity_positive(params)
          # Warning: Don't change the rto warehouse. Changing rto warehouse would produce stock mismatch.
          return_order = create_transfer_order(@current_staff.warehouse, params[:return_transfer_order_params])
          success_response_with_json('Successfully created return transfer order.', HTTP_CODE[:OK],
                                     { id: return_order&.id })
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create return transfer order due to: #{error.message}"
          error!(failure_response_with_json("Unable to create return transfer order due to: #{error.message}",
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'change return transfer order status ready_to_ship to Ready to in_transit'
        route_param :id do
          put 'in_transit' do
            unless check_dh_warehouse
              error!(respond_with_json('Access denied.', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end

            rt_order_id = params[:id]
            rt_order = @current_staff.warehouse.return_transfer_orders.where(id: rt_order_id, is_deleted: false).first

            unless rt_order.present?
              return respond_with_json("Return transfer order id: #{rt_order_id} not found", HTTP_CODE[:NOT_FOUND])
            end

            updated_order = nil
            if rt_order.order_status == 'ready_to_ship' && rt_order.all_boxed? == true
              updated_order = rt_order.update!(order_status: ReturnTransferOrder.getOrderStatus(:in_transit), changed_by: @current_staff)
            end

            if updated_order
              # ShopothWarehouse::V1::Entities::DhPurchaseOrders.represent(rt_order,
              #                                                            warehouse: @current_staff.warehouse)
              updated_order
            else
              respond_with_json('unable to update', HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          rescue => error
            respond_with_json("Unable to update return transfer order status due to: #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Change return transfer order status in_transit to received_to_wh.'
        route_param :id do
          put '/received_to_wh' do
            unless check_wh_warehouse
              error!(respond_with_json('Access denied.', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end

            rt_order_id = params[:id]
            rt_order = ReturnTransferOrder.find_by(id: rt_order_id, is_deleted: false)

            unless rt_order.present?
              return respond_with_json("Return transfer order id: #{rt_order_id} not found", HTTP_CODE[:NOT_FOUND])
            end

            updated_order = nil
            if rt_order.order_status == 'in_transit'
              updated_order = rt_order.update!(order_status: ReturnTransferOrder.getOrderStatus(:received_to_cwh), changed_by: @current_staff)
            end

            if updated_order
              # ShopothWarehouse::V1::Entities::DhPurchaseOrders.represent(dh_purchase_order,
              #                                                            warehouse: @current_staff.warehouse)
              # update qc_pending_quantity for all rto line items
              warehouse_id = @current_staff&.warehouse&.id
              rt_order.line_items.map do |line_item|
                wv = WarehouseVariant.find_or_create_by(warehouse_id: warehouse_id, variant_id: line_item.variant_id)
                wv.update!(qc_pending_quantity: wv.qc_pending_quantity + line_item.send_quantity)
                wv.save_stock_change('rto_qc_pending', line_item.send_quantity, rt_order, nil , 'qc_pending_quantity_change')
              end
              updated_order
            else
              respond_with_json('unable to update', HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end

          rescue StandardError => error
            error! respond_with_json("Unable to change order status #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        resource :boxes do
          desc 'Box create with line item'
          params do
            requires :rt_order_id, type: Integer
            requires :line_item_ids, type: Array, allow_blank: false
          end
          post do
            unless check_dh_warehouse
              error!(respond_with_json('Access denied.', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end
            rt_order = ReturnTransferOrder.find_by(id: params[:rt_order_id])
            if rt_order.present?
              line_items = rt_order.boxable_check(params[:line_item_ids], params[:line_item_ids].size)
              if line_items[:boxable] == false
                status :not_found
                {
                  message: line_items[:message],
                  status_code: HTTP_CODE[:NOT_FOUND],
                }
              else
                ActiveRecord::Base.transaction do
                  rt_order.create_box(line_items[:items], @current_staff.id)
                  respond_with_json('Successfully created box', HTTP_CODE[:OK])
                end
              end
            else
              status :not_found
              {
                message: 'Return transfer order not found',
                status_code: HTTP_CODE[:NOT_FOUND],
              }
            end
          rescue => error
            Rails.logger.info "box_create_api: #{__FILE__} #{error.message}"
            error!(respond_with_json('Failed to create box.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Remove item from box'
          params do
            requires :rt_order_id, type: Integer
            requires :line_item_id, type: Integer
            requires :box_id, type: Integer
          end
          delete 'item_remove' do
            unless check_dh_warehouse
              error!(respond_with_json('Access denied.', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end

            rt_order = ReturnTransferOrder.find_by(id: params[:rt_order_id])
            unless rt_order.present?
              error!(respond_with_json('Unable to remove. reason: requested return transfer order not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            line_item = rt_order.line_items.find_by(id: params[:line_item_id])
            box = rt_order.boxes.unpacked.find_by(id: params[:box_id])
            if line_item.present? && box.present?
              box_item = check_box_item(box.id, line_item.id)
              box_item.destroy!
              box.destroy! if box.box_line_items.count.zero?
              respond_with_json('Successfully deleted', HTTP_CODE[:OK])
            else
              status :not_found
              respond_with_json('Unable to remove. reason: requested line item or box not found')
            end
          rescue => error
            Rails.logger.info "box_item_delete: #{__FILE__} #{error.message}"
            error!(respond_with_json('Failed to delete item.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Box delete'
          params do
            requires :rt_order_id, type: Integer
            requires :box_id, type: Integer
          end
          delete :remove do
            unless check_dh_warehouse
              error!(respond_with_json('Access denied.', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end

            rt_order = ReturnTransferOrder.find_by(id: params[:rt_order_id])
            unless rt_order.present?
              error!(respond_with_json('Unable to remove. reason: requested return transfer order not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            box = rt_order.boxes.unpacked.find_by(id: params[:box_id])
            unless box.present?
              error!(respond_with_json('Unable to remove. reason: requested box not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            if box.box_line_items.present?
              box.box_line_items.destroy_all
              box.destroy!
              respond_with_json('Successfully deleted', HTTP_CODE[:OK])
            else
              status :not_found
              respond_with_json('Unable to delete box. reason: requested box not found', HTTP_CODE[:NOT_FOUND])
            end
          rescue => error
            Rails.logger.info "box_delete: #{__FILE__} #{error.message}"
            error!(respond_with_json('Failed to delete box', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Move Item'
          params do
            requires :line_item_ids, type: Array, allow_blank: false
            requires :rt_order_id, type: Integer
            requires :box_id, type: Integer
          end
          put :move do
            unless check_dh_warehouse
              error!(respond_with_json('Access denied.', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end

            rt_order = ReturnTransferOrder.find_by(id: params[:rt_order_id])
            unless rt_order.present?
              error!(respond_with_json('Unable to move. reason: requested return transfer order not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            box = rt_order.boxes.unpacked.find_by(id: params[:box_id])
            unless box.present?
              error!(respond_with_json('Unable to move. reason: requested box not found.',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            items = rt_order.line_items_check(params[:line_item_ids], params[:line_item_ids].size)
            if items[:boxable] == false
              error!(respond_with_json('Unable to move. reason: requested line items not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            box_items = BoxLineItem.where(line_item_id: items[:items].ids)
            unless box_items.empty?
              current_box_id = box_items.pluck(:box_id).uniq
              current_box = rt_order.boxes.unpacked.find_by(id: current_box_id[0])
              if current_box.id == box.id
                error!(respond_with_json('Unable to move. reason: You can not move items in the same box',
                                         HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
              unless current_box_id.size == 1 || current_box.present?
                error!(respond_with_json('Unable to move. reason: current box is already packed or requested items
                are present in multiple boxes', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
              end
              box_items.destroy_all
              current_box.destroy! if current_box.box_line_items.count.zero?
            end
            box.box_line_items.create!(rt_order.box_items(items[:items]))
            respond_with_json('Successfully moved', HTTP_CODE[:OK])
          rescue => error
            Rails.logger.info "box item move: #{__FILE__} #{error.message}"
            error!(respond_with_json('Failed to move items', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Pack a box.'
          params do
            requires :rt_order_id, type: Integer
            requires :box_id, type: Integer
            requires :line_items, type: Array do
              requires :line_item_id, type: Integer
              requires :location_id, type: Integer
              requires :sku, type: String
              requires :quantity, type: Integer
            end
          end
          put :pack do
            warehouse = @current_staff.warehouse
            unless check_dh_warehouse
              error!(respond_with_json("Central warehouse can't pack return transfer order.",
                                       HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
            end

            transfer_order = warehouse.return_transfer_orders.find_by(id: params[:rt_order_id])
            unless transfer_order.present?
              error!(respond_with_json('Unable to pack. reason: return transfer order not found.',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end

            box = transfer_order.boxes.unpacked.find_by(id: params[:box_id])
            unless box.present?
              error!(respond_with_json('Unable to pack. reason: requested box not found.',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end

            packable = BoxLineItem.packable(params[:line_items], box)
            unless packable[:packable]
              error!(respond_with_json((packable[:message]).to_s, HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end

            item_quantity_available?(params[:line_items], transfer_order, warehouse)
            order_updated = transfer_order.transfer_order_stock_update(params[:line_items], warehouse)
            fail StandardError, "Line items isn't updated properly." unless order_updated

            box.update!(status: :packed)
            if transfer_order.all_boxed? == true
              transfer_order.update!(order_status: ReturnTransferOrder.getOrderStatus(:ready_to_ship), changed_by: @current_staff)
            end
            respond_with_json('Successfully packed.', HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.info "\n#{__FILE__}\nFailed to pack box due to: #{error.message}"
            error!(respond_with_json("Failed to pack box due to: #{error.message}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
