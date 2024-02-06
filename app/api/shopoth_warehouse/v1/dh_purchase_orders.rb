module ShopothWarehouse
  module V1
    class DhPurchaseOrders < ShopothWarehouse::Base
      helpers do
        def json_response(product)
          product.as_json(
            only: %i(title bn_title),
            include: [
              variants: {
                only: %i(id sku product_id sku_code bn_sku_code product_size price_distribution),
              },
            ],
          )
        end

        def po_variants_location_update(line_items, dh_order)
          quantity_updated_count = 0
          ActiveRecord::Base.transaction do
            line_items.each do |line_item|
              quantity = line_item[:quantity]
              fail ActiveRecord::Rollback unless quantity.positive?

              sku = line_item[:sku]
              warehouse = @current_staff.warehouse
              item = dh_order.line_items.find(line_item[:line_item_id])
              warehouse_variant = item.variant.warehouse_variants.find_by(warehouse: warehouse)
              warehouse_variants_location = warehouse_variant.warehouse_variants_locations.find_by(location_id: line_item[:location_id])

              if quantity <= warehouse_variants_location.quantity && item.variant.sku == sku
                warehouse_variants_location.update(quantity: (warehouse_variants_location.quantity - quantity))
                item.update(qr_code: sku, send_quantity: quantity)
                quantity_updated_count += 1
              else
                raise ActiveRecord::Rollback
              end
            end
          end
          line_items.count == quantity_updated_count
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
      end

      # rubocop:disable Metrics/BlockLength
      resource :dh_purchase_orders do
        desc 'Export all Dh_purchase_orders.'
        get 'export' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_day
          dh_purchase_orders = if check_wh_warehouse
                                 DhPurchaseOrder.where(created_at: start_date_time..end_date_time, is_deleted: false).includes(warehouse: [address: :district])
                               else
                                 @current_staff.warehouse.dh_purchase_orders.where(created_at: start_date_time..end_date_time, is_deleted: false).includes(warehouse: [address: :district])
                               end

          if dh_purchase_orders&.present?
            ShopothWarehouse::V1::Entities::PoWithWarehouses.represent(dh_purchase_orders.order(created_at: :desc))
          else
            []
          end
        rescue => error
          error! respond_with_json("Unable to fetch purchase orders due to #{error.message}",
                                   HTTP_CODE[:NOT_FOUND])
        end

        # GET: /dh_purchase_orders
        params do
          use :pagination, per_page: 50
        end

        desc 'Get all Dh_purchase_orders.'
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_day
          dh_purchase_orders = if check_wh_warehouse
                                 DhPurchaseOrder.where(created_at: start_date_time..end_date_time, is_deleted: false).includes(warehouse: [address: :district])
                               else
                                 @current_staff.warehouse.dh_purchase_orders.where(created_at: start_date_time..end_date_time, is_deleted: false).includes(warehouse: [address: :district])
                               end

          dh_purchase_orders = params[:sto_no].present? ? dh_purchase_orders&.where(id: params[:sto_no].to_i) : dh_purchase_orders&.order(created_at: :desc)
          if dh_purchase_orders.present?
            # TODO: Need to Optimize Query
            ShopothWarehouse::V1::Entities::PoWithWarehouses.represent(
              paginate(Kaminari.paginate_array(dh_purchase_orders)),
            )
          else
            []
          end
        rescue => error
          error! respond_with_json("Unable to fetch purchase orders due to #{error.message}",
                                   HTTP_CODE[:NOT_FOUND])
        end

        # Find distribution_price of a specific product variant's.
        # GET: /dh_purchase_orders/:id/variants
        # Here :id means product_id
        desc "Return all variant's distribution price based on product."
        route_param :id do
          get '/variants' do
            product = Product.find(params[:id])
            json_response product
          rescue => error
            error! respond_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # POST: /dh_purchase_orders
        # desc 'Create a new Dh_purchase_order'
        # params do
        #   requires :warehouse_id, type: Integer
        #   optional :logistic_id, type: Integer
        #   requires :order_by, type: Integer
        #   requires :quantity, type: BigDecimal
        #   optional :bn_quantity, type: BigDecimal
        #   requires :total_price, type: BigDecimal
        #   optional :bn_total_price, type: BigDecimal
        #   requires :status, type: String
        #   optional :bn_status, type: String
        # end
        #
        # post do
        #   dh_purchase_order = DhPurchaseOrder.new(params)
        #   dh_purchase_order if dh_purchase_order.save!
        # rescue => error
        #   error! respond_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        # end

        desc 'Return a Dh purchase order.'
        get ':id' do
          purchase_order = if check_wh_warehouse
                             DhPurchaseOrder.find_by(id: params[:id])
                           else
                             @current_staff&.warehouse&.dh_purchase_orders&.find_by(id: params[:id], is_deleted: false)
                           end

          unless purchase_order
            error!(respond_with_json('Purchase order not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          ShopothWarehouse::V1::Entities::DhPurchaseOrders.represent(purchase_order,
                                                                     warehouse: @current_staff.warehouse)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\n Unable to fetch purchase order details due to: #{error.message}"
          error!(respond_with_json('Unable to fetch purchase order details.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # PUT: /dh_purchase_orders/:id
        desc 'Update a Dh_purchase_order'
        route_param :id do
          put do
            dh_purchase_order = @current_staff.warehouse.dh_purchase_orders.where(id: params[:id], is_deleted: false)&.first
            update_params = params.merge(changed_by: @current_staff)
            dh_purchase_order if dh_purchase_order.update!(update_params)
          rescue => error
            error! respond_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        # DELETE: /dh_purchase_orders/:id
        desc 'Delete a Dh_purchase_order'
        route_param :id do
          delete do
            dh_purchase_order =
              @current_staff.warehouse.dh_purchase_orders.where(id: params[:id], is_deleted: false)&.first
            'Successfully deleted.' if dh_purchase_order.update!(is_deleted: true)
          rescue StandardError
            error! respond_with_json('Unable to delete DH_Purchase_Order.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'change order status order_placed to Ready to ship'
        params do
          requires :line_items, type: Array do
            requires :line_item_id, type: Integer
            requires :location_id, type: Integer
            requires :sku, type: String
            requires :quantity, type: Integer
          end
        end

        put ':id/ready_to_ship' do
          unless check_wh_warehouse
            error!(respond_with_json('Access denied.', HTTP_CODE[:FORBIDDEN]),
                   HTTP_CODE[:FORBIDDEN])
          end

          dh_order = DhPurchaseOrder.find_by(id: params[:id])

          unless dh_order.present?
            error!(respond_with_json("Order with id: #{params[:id]} not found.", HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          unless dh_order.order_status == 'order_placed'
            error!(respond_with_json('A STO can be packed only when status is order_placed.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          unless params[:line_items].count == dh_order.line_items.count
            error!(respond_with_json('All products of STO have to pack at a time.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          if po_variants_location_update(params[:line_items], dh_order)
            dh_order.update!(order_status: DhPurchaseOrder.getOrderStatus(:ready_to_ship), changed_by: @current_staff)
            status :ok
            ShopothWarehouse::V1::Entities::PurchaseOrders.represent(dh_order, warehouse: @current_staff.warehouse)
          else
            error!(respond_with_json('Unable to update due to unavailable quantity or unmatched sku.',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError
          respond_with_json('Unable to update Order status.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'change order status ready_to_ship to Ready to in_transit'
        route_param :id do
          put 'in_transit' do
            order_id = params[:id]
            dh_order = if check_dh_warehouse
                         @current_staff.warehouse.dh_purchase_orders.where(id: order_id, is_deleted: false).first
                       else
                         DhPurchaseOrder.find(order_id)
                       end
            unless dh_order.present?
              return respond_with_json("Order with id: #{order_id} not found", HTTP_CODE[:NOT_FOUND])
            end

            updated_order = nil
            if dh_order.order_status == 'ready_to_ship' && dh_order.all_boxed? == true
              updated_order = dh_order.update!(order_status: DhPurchaseOrder.getOrderStatus(:in_transit), changed_by: @current_staff)
            end

            if updated_order
              ShopothWarehouse::V1::Entities::DhPurchaseOrders.represent(dh_order,
                                                                         warehouse: @current_staff.warehouse)
            else
              respond_with_json('unable to update', HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          rescue => ex
            respond_with_json("Unable to update Order status due to: #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Change order status in_transit to received_to_dh.'
        route_param :id do
          put '/received_to_dh' do
            order_id = params[:id]
            dh_purchase_order = if check_dh_warehouse
                                  @current_staff.warehouse.dh_purchase_orders.where(id: order_id, is_deleted: false).first
                                else
                                  DhPurchaseOrder.find(order_id)
                                end
            unless dh_purchase_order.present?
              return respond_with_json("Order with id: #{order_id} not found", HTTP_CODE[:NOT_FOUND])
            end

            updated_order = nil
            if dh_purchase_order.order_status == 'in_transit'
              updated_order = dh_purchase_order.update!(order_status: DhPurchaseOrder.getOrderStatus(:received_to_dh), changed_by: @current_staff)

              # update qc_pending_quantity for all sto line items
              warehouse_id = @current_staff&.warehouse&.id
              dh_purchase_order.line_items.map do |line_item|
                wv = WarehouseVariant.find_or_create_by(warehouse_id: warehouse_id, variant_id: line_item.variant_id)
                wv.update!(qc_pending_quantity: wv.qc_pending_quantity + line_item.send_quantity)
                wv.save_stock_change('sto_qc_pending', line_item.send_quantity, dh_purchase_order, nil , 'qc_pending_quantity_change')
              end
            end

            if updated_order
              ShopothWarehouse::V1::Entities::DhPurchaseOrders.represent(dh_purchase_order,
                                                                         warehouse: @current_staff.warehouse)
            else
              respond_with_json('unable to update', HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end

          rescue StandardError => error
            error! respond_with_json("Unable to change order status #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        resource :boxes do
          desc 'box items export'
          params do
            requires :box_id, type: Integer
            requires :dh_po_id, type: Integer
          end
          get :export do
            dh_po = DhPurchaseOrder.find_by(id: params[:dh_po_id])
            unless dh_po.present?
              error!(respond_with_json('Unable to export. reason: requested sto not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            box = dh_po.boxes.find_by(id: params[:box_id])
            unless box.present?
              error!(respond_with_json('Unable to export. reason: requested box not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            present box, with: ShopothWarehouse::V1::Entities::Boxes, warehouse: @current_staff.warehouse
          rescue => error
            Rails.logger.info "box_export_api: #{__FILE__} #{error.message}"
            error!(respond_with_json('Failed to export box.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Box create with line item'
          params do
            requires :dh_po_id, type: Integer
            requires :line_item_ids, type: Array, allow_blank: false
          end
          post do
            dh_po = DhPurchaseOrder.find_by(id: params[:dh_po_id])
            if dh_po.present?
              line_items = dh_po.boxable_check(params[:line_item_ids], params[:line_item_ids].size)
              if line_items[:boxable] == false
                status :not_found
                {
                  message: line_items[:message],
                  status_code: HTTP_CODE[:NOT_FOUND],
                }
              else
                ActiveRecord::Base.transaction do
                  dh_po.create_box(line_items[:items], @current_staff.id)
                  respond_with_json('Successfully created box', HTTP_CODE[:OK])
                end
              end
            else
              status :not_found
              {
                message: 'Purchase order not found',
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
            requires :dh_po_id, type: Integer
            requires :line_item_id, type: Integer
            requires :box_id, type: Integer
          end
          delete 'item_remove' do
            dh_po = DhPurchaseOrder.find_by(id: params[:dh_po_id])
            unless dh_po.present?
              error!(respond_with_json('Unable to remove. reason: requested sto not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            line_item = dh_po.line_items.find_by(id: params[:line_item_id])
            box = dh_po.boxes.unpacked.find_by(id: params[:box_id])
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
            requires :dh_po_id, type: Integer
            requires :box_id, type: Integer
          end
          delete :remove do
            dh_po = DhPurchaseOrder.find_by(id: params[:dh_po_id])
            unless dh_po.present?
              error!(respond_with_json('Unable to remove. reason: requested sto not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            box = dh_po.boxes.unpacked.find_by(id: params[:box_id])
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
            requires :dh_po_id, type: Integer
            requires :box_id, type: Integer
          end
          put :move do
            dh_po = DhPurchaseOrder.find_by(id: params[:dh_po_id])
            unless dh_po.present?
              error!(respond_with_json('Unable to move. reason: requested sto not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            box = dh_po.boxes.unpacked.find_by(id: params[:box_id])
            unless box.present?
              error!(respond_with_json('Unable to move. reason: requested box not found.',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            items = dh_po.line_items_check(params[:line_item_ids], params[:line_item_ids].size)
            if items[:boxable] == false
              error!(respond_with_json('Unable to move. reason: requested line items not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            box_items = BoxLineItem.where(line_item_id: items[:items].ids)
            unless box_items.empty?
              current_box_id = box_items.pluck(:box_id).uniq
              current_box = dh_po.boxes.unpacked.find_by(id: current_box_id[0])
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
            box.box_line_items.create!(dh_po.box_items(items[:items]))
            respond_with_json('Successfully moved', HTTP_CODE[:OK])
          rescue => error
            Rails.logger.info "box item move: #{__FILE__} #{error.message}"
            error!(respond_with_json('Failed to move items', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Pack a box.'
          params do
            requires :dh_po_id, type: Integer
            requires :box_id, type: Integer
            requires :line_items, type: Array do
              requires :line_item_id, type: Integer
              requires :location_id, type: Integer
              requires :sku, type: String
              requires :quantity, type: Integer
            end
          end
          put :pack do
            dh_po = DhPurchaseOrder.find_by(id: params[:dh_po_id])
            unless dh_po.present?
              error!(respond_with_json('Unable to pack. reason: requested sto not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            box = dh_po.boxes.unpacked.find_by(id: params[:box_id])
            unless box.present?
              error!(respond_with_json('Unable to pack. reason: requested box not found',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end
            packable = BoxLineItem.packable(params[:line_items], box)
            if packable[:packable] == false
              error!(respond_with_json((packable[:message]).to_s, HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end

            unless params[:line_items].size == dh_po.line_items.where(id: params[:line_items].pluck(:line_item_id)).uniq.size
              error!(respond_with_json('Please give items correctly.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end

            availability = dh_po.item_quantity_available?(params[:line_items])
            unless availability.all?(true)
              error!(respond_with_json('Item quantity not available.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end

            box.update!(status: :packed) if po_variants_location_update(params[:line_items], dh_po)
            if dh_po.all_boxed? == true
              dh_po.update!(order_status: DhPurchaseOrder.getOrderStatus(:ready_to_ship), changed_by: @current_staff)
            end
            respond_with_json('Successfully packed', HTTP_CODE[:OK])
          rescue => error
            Rails.logger.info "box item pack: #{__FILE__} #{error.message}"
            error!(respond_with_json('Failed to pack box', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
