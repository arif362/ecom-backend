module ShopothWarehouse
  module V1
    class WhPurchaseOrders < ShopothWarehouse::Base
      resource :wh_purchase_orders do
        desc 'Export all Wh_purchase_orders.'
        get 'export' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          wh_purchase_orders = check_wh_warehouse ? WhPurchaseOrder.all : nil
          return [] unless wh_purchase_orders.present?

          date_range = start_date_time..end_date_time
          wh_purchase_orders = wh_purchase_orders.where(created_at: date_range)
          if wh_purchase_orders.present?
            present wh_purchase_orders.order(created_at: :desc), with: ShopothWarehouse::V1::Entities::PurchaseOrderList
          else
            []
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch WhPurchaseOrder list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch WhPurchaseOrder list.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # GET: /wh_purchase_orders
        params do
          use :pagination, per_page: 50
        end

        desc 'Get all Wh_purchase_orders.'
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
          wh_purchase_orders = check_wh_warehouse ? WhPurchaseOrder.all : nil
          return [] unless wh_purchase_orders.present?

          date_range = start_date_time..end_date_time
          wh_purchase_orders = wh_purchase_orders.where(created_at: date_range)
          if wh_purchase_orders.present?
            # TODO: Need to Optimize Query
            present paginate(Kaminari.paginate_array(wh_purchase_orders.order(created_at: :desc))), with:
              ShopothWarehouse::V1::Entities::PurchaseOrderList
          else
            []
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch WhPurchaseOrder list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch WhPurchaseOrder list.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Return a purchase order.'
        get ':id' do
          purchase_order = check_wh_warehouse ? WhPurchaseOrder.find_by(id: params[:id]) : nil
          unless purchase_order
            error!(respond_with_json('WhPurchaseOrder not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          present purchase_order, with: ShopothWarehouse::V1::Entities::PurchaseOrders
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch WhPurchaseOrder due to: #{error.message}"
          error!(respond_with_json('Unable to fetch WhPurchaseOrder.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # Find supplier_price of a specific product variant's.
        # GET: /wh_purchase_orders/:id/supplier_variant_search
        # Here :id means product_id
        desc 'Return all supplier_variant based on variant_id.'
        route_param :id do
          get '/supplier_variant_search' do
            product = Product.find(params[:id])
            present product, with: ShopothWarehouse::V1::Entities::PurchaseOrderProducts
          rescue StandardError => error
            error! respond_with_json(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Receive a PO'
          put :receive do
            unless check_wh_warehouse
              error!(respond_with_json('You are not allowed', HTTP_CODE[:FORBIDDEN]), HTTP_CODE[:FORBIDDEN])
            end

            po = WhPurchaseOrder.order_placed.find_by(id: params[:id])
            po.update!(order_status: :received_to_cwh, changed_by: @current_staff)

            # update qc_pending_quantity for all po line items
            warehouse_id = @current_staff&.warehouse&.id
            po.line_items.map do |line_item|
              wv = WarehouseVariant.find_or_create_by(warehouse_id: warehouse_id, variant_id: line_item.variant_id)
              wv.update!(qc_pending_quantity: wv.qc_pending_quantity + line_item.quantity)
              wv.save_stock_change('po_qc_pending', line_item.quantity, po, nil , 'qc_pending_quantity_change')
            end
            respond_with_json('Successfully Received', HTTP_CODE[:OK])
          rescue StandardError => error
            Rails.logger.error "\n#{__FILE__}\nFailed to receive this po due to: #{error.full_message}"
            error!(respond_with_json('Failed to receive this po', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
