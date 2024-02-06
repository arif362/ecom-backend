# frozen_string_literal: true

module ShopothCustomerCare
  module V1
    class CustomerOrders < ShopothCustomerCare::Base
      helpers ShopothCustomerCare::V1::Serializers::CustomerOrderSerializer
      helpers do
        def update_customer_order(order, order_status, shipping_type, new_partner_id)
          if %w(order_placed order_confirmed ready_to_shipment).include?(order_status.order_type)
            order.update!(shipping_type: shipping_type, partner_id: new_partner_id,
                          status: order_status, changed_by: @current_customer_care_agent)
          elsif CustomerOrder.shipping_types[order.shipping_type] == shipping_type && order_status.order_type == 'in_transit'
            order.update!(partner_id: new_partner_id, status: order_status, changed_by: @current_customer_care_agent)
          else
            order.update!(next_shipping_type: shipping_type, next_partner_id: new_partner_id,
                          status: order_status, changed_by: @current_customer_care_agent)
          end
          Rails.logger.info 'Successfully Updated customer_order for pick_up_point.'
        end

        def find_order_status(order, existing_partner, new_partner, shipping_type)
          if existing_partner == new_partner || (existing_partner.route == new_partner.route && existing_partner.schedule == new_partner.schedule)
            status = OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit])
          elsif existing_partner != new_partner && CustomerOrder.shipping_types[order.shipping_type] == shipping_type
            status = OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_partner_switch])
          elsif existing_partner.blank? && (order.home_delivery? || order.express_delivery?)
            status = OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_delivery_switch])
          end
          status
        end

        def order_update(order, shipping_type, address_id, prev_shipping_charge, previous_vat)
          order_shipping_charge = Configuration.order_shipping_charge('home_delivery')
          vat = vat_charge(order_shipping_charge)
          order.update!(
            partner_id: nil, shipping_type: shipping_type, shipping_address_id: address_id,
            billing_address_id: address_id, shipping_charge: order_shipping_charge,
            total_price: (order.total_price + (order_shipping_charge + vat) - (prev_shipping_charge + previous_vat)),
            vat_shipping_charge: vat
          )
        end

        def update_to_delivery_switch(order, order_status, shipping_type, address_id, prev_shipping_charge, previous_vat)
          order_shipping_charge = Configuration.order_shipping_charge('home_delivery')
          vat = vat_charge(order_shipping_charge)
          order.update!(
            status: order_status, next_shipping_type: shipping_type,
            shipping_address_id: address_id, billing_address_id: address_id,
            changed_by: @current_customer_care_agent, shipping_charge: order_shipping_charge,
            total_price: (order.total_price + (order_shipping_charge + vat) - (prev_shipping_charge + previous_vat)),
            vat_shipping_charge: vat
          )
        end

        def sr_notification(order, route)
          app_notification = AppNotification.sr_note(order)
          PushNotification::CreateAppNotifications.call(
            app_user: route,
            title: app_notification[:title],
            bn_title: app_notification[:bn_title],
            message: app_notification[:message],
            bn_message: app_notification[:bn_message],
          )
          Rails.logger.info 'Successfully Notified SR.'
        end

        def previous_partner_notification(order, existing_partner)
          app_notification = AppNotification.previous_partner_note(order)
          PushNotification::CreateAppNotifications.call(
            app_user: existing_partner,
            title: app_notification[:title],
            bn_title: app_notification[:bn_title],
            message: app_notification[:message],
            bn_message: app_notification[:bn_message],
          )
          Rails.logger.info 'Successfully Notified previous_partner.'
        end

        def new_partner_notification(order, new_partner)
          app_notification = AppNotification.new_partner_note(order)
          PushNotification::CreateAppNotifications.call(
            app_user: new_partner,
            title: app_notification[:title],
            bn_title: app_notification[:bn_title],
            message: app_notification[:message],
            bn_message: app_notification[:bn_message],
          )
          Rails.logger.info 'Successfully Notified new_partner.'
        end

        def vat_charge(shipping_charge)
          (shipping_charge * 0.15).round
        end
      end

      resource :customer_orders do
        desc 'Show all orders of all customers'
        params do
          use :pagination, per_page: 50
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : nil
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : nil
          all_customer_orders = CustomerOrder.all
          return [] unless all_customer_orders.present?

          all_customer_orders = all_customer_orders.where(id: params[:order_no]) if params[:order_no].present?
          all_customer_orders = all_customer_orders.where(shipping_type: params[:shipping_type]) if params[:shipping_type].present?
          all_customer_orders = all_customer_orders.joins(:partner).where(partners: { schedule: params[:schedule] }) if params[:schedule].present?
          all_customer_orders = all_customer_orders.joins(:status).where(order_statuses: { order_type: params[:status] }) if params[:status].present?
          all_customer_orders = all_customer_orders.where(created_at: start_date_time.to_date.beginning_of_day..end_date_time.to_date.end_of_day) if start_date_time.present? && end_date_time.present?
          if all_customer_orders.present?
            present paginate(Kaminari.paginate_array(all_customer_orders.order(created_at: :desc))), with: ShopothCustomerCare::V1::Entities::CustomerOrders::List
          else
            status :not_found
            { success: false, message: 'Customer orders not found' }
          end
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get details of specific customer order for customer care agent'
        get '/details/:id' do
          order = CustomerOrder.find(params[:id])
          present order, with: ShopothCustomerCare::V1::Entities::CustomerOrders::Details
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Cancel the customer order from customer care agent.'
        patch '/cancel/:id' do
          params do
            requires :cancellation_reason, type: string
          end
          order = CustomerOrder.find_by(id: params[:id])

          unless order
            error!(respond_with_json('Customer Order not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          cancellation_reason = params[:cancellation_reason]
          statuses = %w(delivered_to_partner completed cancelled sold_to_partner
                        in_transit_cancelled packed_cancelled returned_from_customer
                        partially_returned returned_from_partner cancelled_at_dh
                        cancelled_at_in_transit_to_dh)
          if statuses.include?(order&.status&.order_type)
            error!(respond_with_json("This order can't be cancelled.", HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:NOT_ACCEPTABLE])
          elsif cancellation_reason.blank?
            status :unprocessable_entity
            { success: false, message: "Cancellation reason can't be empty." }
          else
            cancelled_status = if order.status.in_transit? || order.status.on_hold? || order.status.in_transit_partner_switch? || order.status.in_transit_delivery_switch? || order.status.in_transit_reschedule?
                                 OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_cancelled])
                               elsif order.status.ready_to_ship_from_fc?
                                 OrderStatus.getOrderStatus(OrderStatus.order_types[:packed_cancelled])
                               elsif order.status.ready_to_shipment?
                                 OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled_at_dh])
                               elsif order.status.order_placed? || order.status.order_confirmed?
                                 OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled])
                               elsif order.status.in_transit_to_dh?
                                 OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled_at_in_transit_to_dh])
                               end
            order.update!(status: cancelled_status, cancellation_reason: cancellation_reason,
                          changed_by: @current_customer_care_agent)
            get_cancelled_order(order)
          end
        rescue StandardError => error
          Rails.logger.error "Unable to cancel #{error.message}"
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Show all shipping types'
        get '/shipping_types' do
          CustomerOrder::shipping_types
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Change shipping a customer order.'
        patch '/change_shipping/:id' do
          params do
            requires :shipping_type, type: Integer
            optional :partner_id, type: Integer
            optional :new_address, type: Hash do
              requires :district_id, type: Integer
              requires :thana_id, type: Integer
              requires :area_id, type: Integer
              requires :address_line, type: String
            end
          end
          order = CustomerOrder.find(params[:id])
          warehouse = order.warehouse
          change_shipping_type = [CustomerOrder.shipping_types[:home_delivery], CustomerOrder.shipping_types[:express_delivery]]
          if warehouse.warehouse_type == 'member' && change_shipping_type.include?(params[:shipping_type].to_i)
            error!(respond_with_json('Not allowed to change shipping type', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
          existing_partner = order&.partner
          shipping_type = params[:shipping_type]&.to_i
          order_status = order.status
          previous_shipping_charge = order.shipping_charge
          previous_vat = order.vat_shipping_charge
          is_pick_up_point = order.pick_up_point?
          unchanged_statuses = %w(order_placed order_confirmed ready_to_ship_from_fc)
          statuses = %w(delivered_to_partner completed cancelled sold_to_partner in_transit_cancelled
                        packed_cancelled returned_from_customer returned_from_partner in_transit_to_dh
                        cancelled_at_in_transit_to_dh cancelled_at_dh cancelled_at_in_transit_to_fc)
          if statuses.include?(order.status.order_type)
            error!(respond_with_json("You can't change shipping for this order.", HTTP_CODE[:FORBIDDEN]),
                   HTTP_CODE[:FORBIDDEN])
          end

          unless shipping_type
            error!(respond_with_json('No shipping type provided.', HTTP_CODE[:FORBIDDEN]),
                   HTTP_CODE[:FORBIDDEN])
          end

          if shipping_type == CustomerOrder.shipping_types[:pick_up_point]
            new_partner = order.warehouse.partners.find_by(id: params[:partner_id])
            unless new_partner
              error!(respond_with_json('Partner not found for pick up point.', HTTP_CODE[:NOT_FOUND]),
                     HTTP_CODE[:NOT_FOUND])
            end

            unless unchanged_statuses.include?(order_status.order_type)
              # if existing_partner and new partner's schedule is same then SR can delivery that order in that day.
              order_status = if existing_partner == new_partner || (existing_partner&.route == new_partner.route && existing_partner.schedule == new_partner.schedule)
                               OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit])
                             elsif existing_partner != new_partner && CustomerOrder.shipping_types[order.shipping_type] == shipping_type
                               OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_partner_switch])
                             elsif order.home_delivery? || order.express_delivery?
                               OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_delivery_switch])
                             end
            end

            update_customer_order(order, order_status, shipping_type, new_partner.id)

            if order.shipping_charge.to_f > 0.0
              order_shipping_charge = Configuration.order_shipping_charge('pick_up_point')
              vat = vat_charge(order_shipping_charge)
              order.update!(
                shipping_charge: order_shipping_charge, vat_shipping_charge: vat,
                total_price: (order.total_price.to_f + (order_shipping_charge + vat) - (previous_shipping_charge + previous_vat))
              )
              Rails.logger.info "Successfully updated customer_order's shipping charge."
            end

            new_partner_notification(order, new_partner)
            previous_partner_notification(order, existing_partner) if is_pick_up_point == true
            sr_notification(order, order.partner&.route)
          else
            address = nil
            new_address = params[:new_address]
            if new_address.present?
              address = Address.new(new_address)
              address.name = order.customer&.name
              address.phone = order.customer&.phone
              address.save!
            end

            unless address
              error!(respond_with_json('Shipping address not found for this delivery.',
                                       HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end

            # TODO:  As express delivery is not applicable for shipping change and shipping charge for home delivery is fixed 40 for now.
            if order.home_delivery? && shipping_type == CustomerOrder.shipping_types[:home_delivery]
              order.update!(shipping_address_id: address&.id, billing_address_id: address&.id)
            elsif CustomerOrder.shipping_types[order.shipping_type] != shipping_type && unchanged_statuses.include?(order_status.order_type)
              shipping_type = CustomerOrder.shipping_types[:home_delivery]
              order_update(order, shipping_type, address&.id, previous_shipping_charge, previous_vat)
            else
              order_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_delivery_switch])
              shipping_type = CustomerOrder.shipping_types[:home_delivery]
              update_to_delivery_switch(order, order_status, shipping_type, address&.id, previous_shipping_charge, previous_vat)
            end
            Rails.logger.info 'Successfully Updated customer_order for home_delivery.'

            if is_pick_up_point == true
              previous_partner_notification(order, existing_partner)
              sr_notification(order, existing_partner&.route)
            end
          end
          status :ok
          respond_with_json('Success', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to change shipping of order_id: #{order.id} due to: #{error.message}"
          error!(respond_with_json('Unable to change shipping for this order.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'reschedule a customer order '
        patch '/reschedule/:id' do
          params do
            requires :preferred_delivery_date, type: Date
          end
          order = CustomerOrder.find(params[:id])
          statuses = %w(delivered_to_partner completed cancelled sold_to_partner in_transit_cancelled
                        packed_cancelled partially_returned returned_from_customer returned_from_partner)
          if statuses.include?(order&.status&.order_type)
            error!(respond_with_json("This order can't be rescheduled.", HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:NOT_ACCEPTABLE])
          end
          order.update!(preferred_delivery_date: params[:preferred_delivery_date])
          status :ok
          { success: true, message: 'reschedule is successful' }
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        # NOTE : Below end points for call center
        desc 'Get details of specific customer order for call center'
        route_param :id do
          get do
            order = CustomerOrder.find_by(id: params[:id])
            if order.present?
              get_specific_order_details(order)
            else
              status :not_found
              { success: false, message: 'Order not found' }
            end
          rescue StandardError => error
            error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Cancel the customer order of current agent'
        route_param :id do
          delete do
            order = CustomerOrder.find(params[:id])
            cancelled_status_id = OrderStatus.find_by(order_type: OrderStatus.order_types[:cancelled]).id
            if order.present? && !order.status.completed?
              if order.update!(order_status_id: cancelled_status_id, changed_by: @current_customer_care_agent)
                get_cancelled_order(order)
              end
            else
              status :not_found
              { success: false, message: order.present? ? 'Completed order not possible to cancel' : 'Order not found' }
            end
          rescue StandardError => error
            error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

      end
    end
  end
end
