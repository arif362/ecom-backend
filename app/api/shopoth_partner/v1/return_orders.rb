# frozen_string_literal: true

module ShopothPartner
  module V1
    class ReturnOrders < ShopothPartner::Base
      helpers do
        def get_line_item(order, sku)
          order.shopoth_line_items.select do |line_item|
            line_item.qr_codes.include?(sku)
          end
        end
        #
        # def update_inventory_and_stock_changes(return_order)
        #   customer_order = return_order.customer_order
        #   if return_order.packed?
        #     customer_order.shopoth_line_items.each do |line_item|
        #       update_inventory_and_stock_changes_for_line_item(return_order, line_item)
        #     end
        #   else
        #     update_inventory_and_stock_changes_for_line_item(return_order, return_order.shopoth_line_item)
        #   end
        # end
        #
        # def update_inventory_and_stock_changes_for_line_item(return_order, line_item)
        #   customer_order = return_order.customer_order
        #   quantity = return_order.packed? ? line_item.quantity : 1
        #   warehouse_variant = wv_from_customer_order(customer_order, line_item.variant)
        #   if (warehouse_variant.in_partner_quantity - quantity).negative?
        #     Rails.logger.error "\nIn_partner_quantity is being negative for sku = #{line_item.variant.sku} and warehouse_variant_id: #{warehouse_variant.id}. Action: Partner App -> full parcel return and Line_Item_id: #{line_item.id}\n"
        #   end
        #   warehouse_variant.update!(
        #     in_partner_quantity: warehouse_variant.in_partner_quantity - quantity,
        #     return_in_partner_quantity: warehouse_variant.return_in_partner_quantity + quantity,
        #     )
        #   stock_transfer_type = return_order.packed? ? 'customer_order_packed_returned' : 'customer_order_unpacked_returned'
        #   warehouse_variant.save_stock_change(stock_transfer_type, quantity, line_item.customer_order, nil, 'in_partner_quantity_change')
        #   warehouse_variant.save_stock_change('return_order_in_partner', quantity, line_item.customer_order, 'return_in_partner_quantity_change', nil)
        # end
        #
        # def wv_from_customer_order(customer_order, variant)
        #   customer_order.warehouse.warehouse_variants.find_by(variant: variant)
        # end
      end
      resource 'return' do
        desc 'Partner: Request for full parcel return.'
        params do
          requires :order_id, type: String, allow_blank: false
          requires :reason, type: Integer, allow_blank: false
          requires :description, type: String
        end
        post 'full_parcel' do
          customer_order = @current_partner.customer_orders.find(params[:order_id].to_i)
          if customer_order.partner == @current_partner && customer_order.status.delivered_to_partner?
            return_order = ReturnCustomerOrder.find_by(customer_order_id: customer_order.id,
                                                       partner: @current_partner)

            if return_order.present?
              status :unprocessable_entity
              { success: false, message: I18n.t('Partner.errors.messages.return_order_already_exists') }
            else
              ActiveRecord::Base.transaction do
                return_order = customer_order.return_customer_orders.
                               find_or_create_by(return_type: :packed,
                                                 reason: params[:reason],
                                                 description: params[:description],
                                                 partner: @current_partner,
                                                 form_of_return: :to_partner,
                                                 warehouse_id: customer_order.warehouse_id,
                                                 distributor_id: @current_partner&.route&.distributor_id,
                                                 return_orderable: @current_partner,
                                                 sub_total: customer_order.total_price)
                return_order.update!(return_status: :in_partner, changeable: @current_partner)
                customer_order.update!(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:returned_from_partner]),
                                       changed_by: @current_partner)
                return_order.update_inventory_and_stock_changes('return_in_partner_quantity', 'in_partner_quantity')
              end

              app_notification = AppNotification.return_order_created(return_order)
              attributes = @locale == :bn ? get_hash(app_notification[:bn_title], app_notification[:bn_message]) : get_hash(app_notification[:title], app_notification[:message])
              PushNotification::CreateAppNotificationsPartner.call(
                app_user: @current_partner,
                title: app_notification[:title],
                bn_title: app_notification[:bn_title],
                message: app_notification[:message],
                bn_message: app_notification[:bn_message],
                attributes: attributes,
              )

              status :ok
              { success: true, message: I18n.t('Partner.success.messages.full_parcel') }
            end
          else
            status :unprocessable_entity
            { success: false, message: I18n.t('Partner.errors.messages.full_parcel_wrong_invoice') }
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnsuccessful scanning due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.full_parcel_invalid_order'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Request for partial return'
        params do
          requires :order_id, type: String, allow_blank: false
          requires :qr_code, type: String, allow_blank: false
          requires :reason, type: Integer, allow_blank: false
          optional :quantity, type: Integer
          requires :description, type: String
          optional :images
        end
        post 'partial' do

          customer_order = CustomerOrder.find(params[:order_id].to_i)
          params[:quantity] = 1 unless customer_order.b2b?

          unless customer_order.partner == @current_partner
            status :forbidden
            return { success: false, message: I18n.t('Partner.errors.messages.partial_parcel_wrong_invoice'), status_code: HTTP_CODE[:FORBIDDEN] }
          end

          if customer_order.completed_within_seven_days?
            line_item = get_line_item(customer_order, params[:qr_code])
            if line_item.present? && line_item[0].returnable?
              line_item = line_item[0]
              packed_return = customer_order.return_customer_orders.find_by(return_type: :packed)
              promotion = customer_order.total_discount_amount

              if packed_return.present?
                status :unprocessable_entity
                { success: false, message: I18n.t('Partner.errors.messages.return_order_already_exists') }
              elsif line_item.quantity_valid?(params[:quantity]) == false
                status :unprocessable_entity
                { success: false, message: 'Quantity should be less or equal to the total item quantity of your order'}
              elsif promotion.positive?
                status :unprocessable_entity
                { success: false, message: I18n.t('Partner.errors.messages.promotional_product_return') }
              else
                ActiveRecord::Base.transaction do
                  aggr_return = customer_order.aggregate_return_create
                  return_order = customer_order.return_customer_orders.create!(qr_code: params[:qr_code],
                                                                               reason: params[:reason],
                                                                               quantity: params[:quantity],
                                                                               description: params[:description],
                                                                               images: params[:images],
                                                                               shopoth_line_item: line_item,
                                                                               partner: @current_partner,
                                                                               return_type: :unpacked,
                                                                               form_of_return: :to_partner,
                                                                               warehouse_id: customer_order.warehouse_id,
                                                                               distributor_id: customer_order.distributor_id,
                                                                               return_orderable: @current_partner,
                                                                               sub_total: line_item.effective_unit_price * params[:quantity].to_i,
                                                                               aggregate_return: aggr_return)

                  return_order.update!(return_status: :in_partner, changeable: @current_partner)
                  aggr_return.update_amount(return_order.form_of_return)
                  app_notification = AppNotification.return_order_created(return_order)
                  attributes = @locale == :bn ? get_hash(app_notification[:bn_title], app_notification[:bn_message]) : get_hash(app_notification[:title], app_notification[:message])
                  PushNotification::CreateAppNotificationsPartner.call(
                    app_user: @current_partner,
                    title: app_notification[:title],
                    bn_title: app_notification[:bn_title],
                    message: app_notification[:message],
                    bn_message: app_notification[:bn_message],
                    attributes: attributes,
                  )
                  status :ok
                  { success: true, message: I18n.t('Partner.success.messages.partial_parcel') }
                end
              end
            else
              status :unprocessable_entity
              { success: false, message: I18n.t('Partner.errors.messages.partial_parcel_wrong_qr_code') }
            end
          else
            status :unprocessable_entity
            { success: false, message: I18n.t('Partner.errors.messages.partial_parcel_after_seven_days') }
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnsuccessful scanning due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.partial_parcel_invalid_order'),
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Return Request list.'
        get 'request_list' do
          status_list = %w(initiated in_partner)
          return_orders =
            @current_partner.return_customer_orders.select do |order|
              status_list.include?(order.return_status.to_s)
            end

          present return_orders.sort, with: ShopothPartner::V1::Entities::ReturnCustomerOrders
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to fetch return_orders due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.return_request_not_found'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Returned to SR list.'
        get 'completed_list' do
          status_list = %w(in_transit delivered_to_dh)
          date = Date.today.all_day
          return_orders =
            @current_partner.return_customer_orders.select do |order|
              status_list.include?(order.return_status.to_s) && date.include?(order.created_at)
            end

          present return_orders.sort, with: ShopothPartner::V1::Entities::ReturnCustomerOrders
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to fetch return_orders due to: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.return_request_not_found'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Returned History List.'
        get 'history' do
          status_list = %w(in_transit delivered_to_dh)
          return_orders =
            @current_partner.return_customer_orders.select do |order|
              status_list.include?(order.return_status.to_s)
            end
          return_orders = return_orders.order(:created_at)
          present return_orders, with: ShopothPartner::V1::Entities::ReturnCustomerOrders
        rescue => error
          error! respond_with_json("Unable to find return_orders due to #{error}", HTTP_CODE[:NOT_FOUND])
        end

        desc 'Return Order Details'
        get 'details' do
          params do
            requires :return_id, type: Integer, allow_blank: false
          end

          return_item = @current_partner.return_customer_orders.find_by(id: params[:return_id])
          if return_item.present?
            present return_item, with: ShopothPartner::V1::Entities::ReturnLineItem
          else
            status :not_found
            { success: false, message: I18n.t('Partner.errors.messages.return_request_not_found') }
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to show return_order details. Reason: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.return_details_fetch_failed'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Details for Return item.'
        params do
          requires :order_id, type: String
          requires :scan_code, type: String
          requires :return_type, type: String
        end
        get 'order_details' do
          customer_order = CustomerOrder.find(params[:order_id].to_i)
          unless customer_order.partner == @current_partner
            status :forbidden
            return { success: false, message: I18n.t('Partner.errors.messages.partial_parcel_wrong_invoice'), status_code: HTTP_CODE[:FORBIDDEN] }
          end
          return_type = params[:return_type]
          unless %w(packed unpacked).include?(return_type)
            status :not_found
            return { message: 'Return type is not provided!', status_code: HTTP_CODE[:NOT_FOUND] }
          end

          case return_type
          when 'packed'
            scanned_customer_order = @current_partner.customer_orders.find(params[:scan_code])
            unless scanned_customer_order.present?
              status :not_found
              return { message: 'You are not authorized!', status_code: HTTP_CODE[:NOT_FOUND] }
            end

            if scanned_customer_order == customer_order
              present customer_order, with: ShopothPartner::V1::Entities::CustomerOrderDetails
            else
              respond_with_json(I18n.t('Partner.errors.messages.mismatched_scanned_code'), HTTP_CODE[:NOT_ACCEPTABLE])
            end
          when 'unpacked'
            line_item = get_line_item(customer_order, params[:scan_code])
            unless line_item.present?
              status :not_found
              return { message: I18n.t('Partner.errors.messages.return_item_not_found'), status_code: HTTP_CODE[:NOT_FOUND] }
            end

            present line_item[0], with: ShopothPartner::V1::Entities::LineItemProductDetails
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nYou are scanning invalid order no: #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.full_parcel_invalid_order'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        desc 'Scan return item from customer.'
        params do
          requires :return_id, type: Integer
          requires :qr_code, type: String
        end
        put 'scan' do
          return_order = @current_partner.return_customer_orders.find(params[:return_id])
          if return_order.shopoth_line_item.qr_codes[0] == params[:qr_code] && return_order.initiated?
            return_order.update!(return_status: :in_partner, changeable: @current_partner)
            return_order.update_inventory_and_stock_changes('return_in_partner_quantity')
            status :ok
            respond_with_json(I18n.t('Partner.success.messages.partial_parcel_receive'), HTTP_CODE[:OK])
          else
            status :unprocessable_entity
            respond_with_json(I18n.t('Partner.errors.messages.partial_parcel_wrong_qr_code'),
                              HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        rescue StandardError => error
          Rails.logger.error "#{__FILE__} \nUnable to fetch statement due to: #{error.message}"
          status :unprocessable_entity
          respond_with_json(I18n.t('Partner.errors.messages.return_order_not_found'), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
