module ShopothWarehouse
  module V1
    class Qcs < ShopothWarehouse::Base
      resource :qcs do
        desc 'fetch individual line item'
        params do
          requires :order_id, type: Integer
          requires :line_item_id, type: Integer
          optional :order_type, type: String
        end

        get 'line_item' do
          order_id = params[:order_id]
          line_item_id = params[:line_item_id]
          warehouse = @current_staff&.warehouse
          warehouse_type = warehouse.warehouse_type if warehouse.present?
          order = case warehouse_type
                  when 'central'
                    params[:order_type].present? && params[:order_type] == 'ReturnTransferOrder' ? return_transfer_order(order_id) : wh_purchase_order(order_id)
                  when 'distribution', 'member', 'b2b'
                    dh_purchase_order(order_id)
                  end
          return {} unless order.present?

          line_item = LineItem.where(id: line_item_id, itemable: order).first

          if line_item
            ShopothWarehouse::V1::Entities::LineItems::LineItemAttributes.represent(
              line_item, warehouse: warehouse
            )
          else
            error!(respond_with_json('Unable to fetch line item.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        rescue StandardError => error
          error! respond_with_json("Unable to fetch line item due to: #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'perform quality control by variant'
        params do
          requires :order, type: Hash do
            requires :order_id, type: Integer
            optional :order_type, type: String
            requires :variant_id, type: Integer
            requires :received_quantity, type: Integer
            requires :passed_quantity, type: Integer
            requires :failed_quantity, type: Integer
            requires :failed_reasons, type: Array
          end
        end

        post '/quality_control' do
          order = params.dig(:order)
          order_id = order.dig(:order_id)
          order_type = order.dig(:order_type)
          variant_id = order.dig(:variant_id)
          received_quantity = order.dig(:received_quantity)
          passed_quantity = order.dig(:passed_quantity)
          failed_quantity = order.dig(:failed_quantity)
          failed_reasons = order.dig(:failed_reasons)
          error! respond_with_json('Please provide valid data', HTTP_CODE[:UNPROCESSABLE_ENTITY]) unless !!(order_id && variant_id && received_quantity && passed_quantity)

          if %w(distribution member b2b).include?(@current_staff&.warehouse&.warehouse_type)
            purchase_order = DhPurchaseOrder.find(order_id)
            line_item = LineItem.find_by(itemable: purchase_order, variant_id: variant_id)
            unless received_quantity <= line_item&.send_quantity
              error!(respond_with_json('Received quantity can not be grater than send quantity.',
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end

          if @current_staff&.warehouse&.warehouse_type == 'central'
            if order_type.present? && order_type == 'ReturnTransferOrder'
              order = ReturnTransferOrder.received_to_cwh.find(order_id)
              unless order
                error!(respond_with_json('RTO should be received by admin first',
                                         HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
            else
              po = WhPurchaseOrder.received_to_cwh.find_by(id: order_id)
              unless po
                error!(respond_with_json('PO should be received by admin first',
                                         HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
            end
          end

          total_quantity = passed_quantity + failed_quantity
          unless received_quantity == total_quantity
            error! respond_with_json('Please complete QC for the all received quantities',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          line_item_context = QualityControl::ProcessQc.call(order_id: order_id,
                                                             order_type: order_type,
                                                             variant_id: variant_id,
                                                             warehouse_id: @current_staff&.warehouse&.id,
                                                             received_quantity: received_quantity,
                                                             passed_quantity: passed_quantity,
                                                             failed_quantity: failed_quantity,
                                                             failed_reasons: failed_reasons,
                                                             current_staff: @current_staff)
          if line_item_context.success?
            present line_item_context.line_item,
                    with: ShopothWarehouse::V1::Entities::LineItems::LineItemAttributes
          else
            respond_with_json(line_item_context.error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError => ex
          error! respond_with_json("Unable to proceed Quantity Control due to: #{ex.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'fetch product list of a order'
        params do
          requires :order_id, type: Integer
          requires :order_type, type: String
        end

        get 'line_items_by_order' do
          order_id = params[:order_id]
          purchase_order = if params[:order_type] == WhPurchaseOrder::PO_TYPE[:wh]
                             wh_purchase_order(order_id)
                           elsif params[:order_type] == DhPurchaseOrder::PO_TYPE[:dh]
                             dh_purchase_order(order_id)
                           elsif params[:order_type] == ReturnTransferOrder::PO_TYPE[:rto]
                             return_transfer_order(order_id)
                           end
          line_items = purchase_order.line_items

          if line_items
            ShopothWarehouse::V1::Entities::LineItems::LineItemAttributes.represent(
              line_items, warehouse: @current_staff&.warehouse
            )
          else
            error!(respond_with_json('Unable to fetch line items.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
        rescue StandardError => error
          error! respond_with_json("Unable to fetch line items due to: #{error.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get failed items.'
        params do
          use :pagination, per_page: 50
          requires :order_type, type: String
          optional :order_id, type: Integer
          optional :sku, type: String
          optional :code_by_supplier, type: String
        end
        get 'qc_failed_items' do
          order_type = params[:order_type]
          unless %w(DhPurchaseOrder WhPurchaseOrder ReturnCustomerOrder ReturnTransferOrder).include?(order_type)
            error!(failure_response_with_json("Please give order type 'DhPurchaseOrder' or 'WhPurchaseOrder'
                                               or 'ReturnCustomerOrder' or 'ReturnTransferOrder'.",
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          failed_qcs = FailedQc.fetch_orders(order_type, @current_staff.warehouse.id)
          failed_qcs = failed_qcs.where(failable_id: params[:order_id]) if params[:order_id].present?
          if params[:sku].present?
            failed_qcs = failed_qcs.joins(:variant).where('variants.sku = ?', params[:sku])
          end

          if params[:code_by_supplier].present?
            failed_qcs = failed_qcs.joins(:variant).where('variants.code_by_supplier = ?', params[:code_by_supplier])
          end
          # TODO: Need to Optimize Query
          response = ShopothWarehouse::V1::Entities::FailedQcs.represent(
            paginate(Kaminari.paginate_array(failed_qcs)),
          )
          success_response_with_json('Successfully fetched failed qcs.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch failed qcs due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch failed qcs.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Reconcilation of failed items.'
        params do
          requires :failed_qc_id, type: Integer
          requires :action, type: String
          optional :quantity, type: Integer
          optional :location_id, type: Integer
        end
        put 'reconcile' do
          warehouse = @current_staff.warehouse
          failed_qc = warehouse.failed_qcs.find_by(id: params[:failed_qc_id])
          unless failed_qc
            error!(respond_with_json('Failed QC not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
          end

          if failed_qc.is_settled?
            error!(respond_with_json('Already settled!', HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
          end

          if params[:action] == FailedQc::SETTLEMENT_ACTION[:received]
            unless params[:quantity].positive?
              error!(respond_with_json('Cannot receive negative quantity.', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end

            location = warehouse.locations.find_by(id: params[:location_id])
            unless location
              error!(respond_with_json('Wrong location code.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end

            if failed_qc.open_quantity < params[:quantity]
              error!(respond_with_json('Cannot receive more that open quantity.', HTTP_CODE[:FORBIDDEN]),
                     HTTP_CODE[:FORBIDDEN])
            end

            # failed_qc.update!(received_quantity: failed_qc.received_quantity + params[:quantity])
            update_quantity(warehouse, failed_qc, params[:quantity].to_i, location)
            send_response('Quantity received successfully', HTTP_CODE[:OK], true)
          # for closeing failed qc
          else
            failed_qc.update!(closed_quantity: failed_qc.open_quantity, closed_at: Time.now, changed_by: @current_staff)
            send_response('Closed successfully', HTTP_CODE[:OK], true)
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to reconcile due to: #{error.message}"
          error! send_response('Unable to reconcile.', HTTP_CODE[:INTERNAL_SERVER_ERROR], false)
        end
      end

      helpers do
        def send_response(message, status_code, status)
          { message: message, status_code: status_code, success: status }
        end

        def update_quantity(warehouse, failed_qc, quantity, location)
          ActiveRecord::Base.transaction do
            failed_qc.update!(received_quantity: failed_qc.received_quantity + quantity, changed_by: @current_staff)
            warehouse_variant = warehouse.warehouse_variants.find_or_create_by!(variant: failed_qc.variant)
            warehouse_variants_location = warehouse_variant.warehouse_variants_locations.find_or_create_by!(location: location)
            warehouse_variants_location.update!(quantity: warehouse_variants_location.quantity + quantity)
            wv_failed_type = failed_qc.quantity_failed? ? 'qty_qc_failed_quantity' : 'qly_qc_failed_quantity'
            sc_failed_type = failed_qc.quantity_failed? ? 'qty_qc_failed_quantity_change' : 'qly_qc_failed_quantity_change'

            if failed_qc.failable&.class&.name == 'ReturnCustomerOrder'
              failed_qc.failable&.update_inventory_and_stock_changes('available_quantity', 'return_qc_failed_quantity', nil, quantity, failed_qc)
            else
              eval("warehouse_variant.update!(available_quantity: warehouse_variant.available_quantity + quantity, #{wv_failed_type}: warehouse_variant.#{wv_failed_type} - quantity)")
              warehouse_variant.save_stock_change('received_for_failed_qc_sku', quantity, failed_qc, sc_failed_type, 'available_quantity_change')
            end
          end
        end

        def wh_purchase_order(order_id)
          WhPurchaseOrder.find(order_id)
        end

        def dh_purchase_order(order_id)
          DhPurchaseOrder.find(order_id)
        end

        def return_transfer_order(id)
          ReturnTransferOrder.find(id)
        end

        def line_item_quantity(warehouse_type, failed_qc, line_item)
          case warehouse_type
          when 'central'
            line_item_quantity = if failed_qc.quantity_failed?
                                   line_item.quantity
                                 else
                                   line_item.received_quantity
                                 end
          when 'distribution', 'member', 'b2b'
            line_item_quantity = if failed_qc.quantity_failed?
                                   line_item.send_quantity
                                 else
                                   line_item.received_quantity
                                 end
          end
          line_item_quantity
        end

        # def reconcilation_quantity(line_item, failed_qc)
        #   if failed_qc.quality_failed?
        #     line_item_reconcilation_qty = line_item.qc_passed + failed_qc.received_quantity
        #   elsif failed_qc.quantity_failed?
        #     line_item_reconcilation_qty = line_item.received_quantity + failed_qc.received_quantity
        #   end
        #   line_item_reconcilation_qty
        # end

        # def failed_qc_close_quantity(line_item_quantity, line_item, failed_qc)
        #   if failed_qc.quantity_failed?
        #     close_quantity = line_item_quantity - (line_item.received_quantity + failed_qc.received_quantity)
        #   elsif failed_qc.quality_failed?
        #     close_quantity = line_item_quantity - (line_item.qc_passed + failed_qc.received_quantity)
        #   end
        #   close_quantity
        # end
      end
    end
  end
end
