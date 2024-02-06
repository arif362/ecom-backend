# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class Invoices < ShopothWarehouse::Base
      helpers do
        def update_warehouse_variant_quantity(customer_order)
          items = customer_order.shopoth_line_items
          wh_variants = WarehouseVariant.group_by_wh_variant(items, @current_route_device.route.warehouse.id)
          wh_variants.each do |wh_v|
            if (wh_v['wv_id'].ready_to_ship_quantity - wh_v['qty']).negative?
              Rails.logger.error "\nPacked_quantity is being negative for warehouse_variant_id: #{wh_v['wv_id'].id}.
              Action: SR -> Scan Packed customer order: #{wh_v['stock_changeable'].id}\n"
            end
            wh_v['wv_id'].update!(ready_to_ship_quantity: wh_v['wv_id'].ready_to_ship_quantity - wh_v['qty'],
                                  in_transit_quantity: wh_v['wv_id'].in_transit_quantity + wh_v['qty'])
            wh_v['wv_id'].save_stock_change('customer_order_in_transit', wh_v['qty'], wh_v['stock_changeable'],
                                            'ready_to_ship_quantity_change', 'in_transit_quantity_change')
          end
        end

        def schedule_matched?(partner)
          current_day = Date.today.strftime("%A")[0..2].downcase
          partner.schedule.include?(current_day)
        end
      end
      resource :invoices do
        desc 'SR scan packed customer_order invoice.'
        params do
          requires :invoice_id, type: String
          optional :order_id, type: String
        end
        route_setting :authentication, type: RouteDevice
        post 'update_order_status' do
          customer_order = CustomerOrder.find(params[:invoice_id].to_i)
          if params[:order_id].present? && customer_order.id != params[:order_id].to_i
            error!(respond_with_json('Wrong invoice scanned',
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          partner = customer_order.partner
          if partner.route == @current_route_device.route && schedule_matched?(partner)
            if customer_order.status.ready_to_shipment?
              ActiveRecord::Base.transaction do
                customer_order.update!(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit]),
                                       changed_by: @current_route_device)
                update_warehouse_variant_quantity(customer_order)
              end
              status :ok
              customer_order
            else
              status :not_found
              respond_with_json('This order is not ready for shipment', HTTP_CODE[:NOT_FOUND])
            end
          else
            status :not_found
            respond_with_json('Wrong invoice scanned for SR or partner schedule not matched.', HTTP_CODE[:NOT_FOUND])
          end
        rescue => ex
          Rails.logger.info "Sr app invoice scan failed #{ex.message}"
          error!(respond_with_json('Invalid invoice scanned under this sr',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
