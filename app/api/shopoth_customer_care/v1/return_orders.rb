module ShopothCustomerCare
  module V1
    class ReturnOrders < ShopothCustomerCare::Base
      helpers ShopothCustomerCare::V1::Serializers::ReturnOrderSerializer

      helpers do
        def create_return_address(aggr_return, return_form, address_params)
          return if return_form != 'from_home' || address_params.nil? || aggr_return.address.present?

          aggr_return.add_address(address_params)
        end
      end

      resource :return_orders do
        desc 'get return order list'
        params do
          use :pagination, per_page: 50
        end
        get do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc : nil
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc : nil
          return_orders = ReturnCustomerOrder.packed
          return [] unless return_orders.present?

          return_orders = return_orders.where(return_status: params[:return_status]) if params[:return_status].present?
          return_orders = return_orders.joins(:customer_order).where(customer_orders: { id: params[:order_no] }) if params[:order_no].present?
          return_orders = return_orders.where(created_at: start_date_time.to_date.beginning_of_day..end_date_time.to_date.end_of_day) if start_date_time.present? && end_date_time.present?
          if return_orders.present?
            present paginate(Kaminari.paginate_array(return_orders.order(created_at: :desc))), with: ShopothCustomerCare::V1::Entities::ReturnOrders::List
          else
            status :not_found
            { success: false, message: 'Customer orders not found' }
          end
        rescue => ex
          error! respond_with_json("Unable to fetch return list due to #{ex.message}",
                                   HTTP_CODE[:NOT_FOUND])
        end

        desc 'Show all return reasons'
        get '/reasons' do
          ReturnCustomerOrder::reasons
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'create a return request'
        params do
          requires :return_order, type: Hash do
            requires :customer_order_id, type: Integer
            requires :reason, type: Integer
            optional :description, type: String
            requires :shopoth_line_item_id, type: Integer
          end
        end

        post do
          customer_order = CustomerOrder.with_no_discount.find(params[:return_order][:customer_order_id])
          if customer_order.completed_within_seven_days?
            line_item = customer_order.shopoth_line_items.find_by(id: params[:return_order][:shopoth_line_item_id])
            partner = customer_order.pick_up_point? ? customer_order.partner : nil
            return_form = customer_order.pick_up_point? ? 'to_partner' : 'from_home'
            if line_item.present? && line_item.returnable?
              packed_return = customer_order.return_customer_orders.find_by(return_type: :packed)
              promotion = customer_order.total_discount_amount

              if packed_return.present?
                status :unprocessable_entity
                { success: false, message: 'Full Return Order already exists' }
              elsif promotion.positive?
                status :unprocessable_entity
                { success: false, message: 'Promotional product can not be returned.' }
              else
                aggr_return = customer_order.aggregate_return_create
                params[:return_order].merge!(shopoth_line_item: line_item,
                                             partner: partner,
                                             return_type: :unpacked,
                                             warehouse_id: customer_order.warehouse_id,
                                             qr_code: line_item.qr_codes[0],
                                             form_of_return: return_form,
                                             return_orderable: @current_customer_care_agent,
                                             sub_total: line_item.effective_unit_price,
                                             distributor_id: customer_order.distributor_id,
                                             aggregate_return: aggr_return)
                return_order = customer_order.return_customer_orders.create!(params[:return_order])
                aggr_return.update_amount(return_form)
                create_return_address(aggr_return, return_form, customer_order.shipping_address)
                status :ok
                { success: true,
                  message: 'Order return request initiated successfully.',
                  type: return_order.return_type.to_s, }
              end
            else
              status :unprocessable_entity
              { success: false, message: 'Line item not found or already requested' }
            end
          else
            status :unprocessable_entity
            { success: false, message: 'After 7 days of completion product can not be returned' }
          end
        rescue => error
          Rails.logger.info "care-return order initiate failed #{error.message}"
          status :unprocessable_entity
          { success: false, message: 'Discounted order can not be returned or invalid' }
        end

        desc 'Get return customer order'
        route_param :id do
          get do
            return_order = ReturnCustomerOrder.packed.find(params[:id])
            return_details_customer(return_order)
          rescue => error
            error!("Unable to return details due to #{error.message}")
          end
        end

        desc 'reschedule a return request '
        patch '/reschedule/:id' do
          params do
            requires :preferred_delivery_date, type: Date
          end
          return_order = ReturnCustomerOrder.find(params[:id])
          return_order.update!(preferred_delivery_date: params[:preferred_delivery_date])
          status :ok
          { success: true, message: 'reschedule is successful' }
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Cancel a return request.'
        put '/cancel/:id' do
          params do
            requires :cancellation_reason, type: String
          end
          return_order = ReturnCustomerOrder.find(params[:id])
          if return_order.packed?
            status :unprocessable_entity
            { success: false, message: "Packed returned order can't be cancelled." }
          elsif params[:cancellation_reason].blank?
            status :unprocessable_entity
            { success: false, message: 'Cancellation reason empty not accepted' }
          elsif return_order.initiated? || return_order.in_partner?
            aggr_return = return_order.aggregate_return
            return_status = %i(in_transit delivered_to_dh qc_pending relocation_pending completed)
            ret_ord = aggr_return.return_customer_orders.where(return_status: return_status)
            if ret_ord.present?
              error!(respond_with_json('Can not cancel if rider or sr is receiving return items',
                                       HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            return_order.update!(cancellation_reason: params[:cancellation_reason],
                                 return_status: ReturnCustomerOrder::return_statuses[:cancelled],
                                 changeable: @current_customer_care_agent)
            aggr_return.update_amount(return_order.form_of_return)
            status :ok
            { success: true, message: 'Return request cancel is successful' }
          else
            status :unprocessable_entity
            { success: false, message: "Returned order can't be cancelled." }
          end
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

      end
    end
  end
end
