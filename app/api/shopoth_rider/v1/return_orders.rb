# frozen_string_literal: true

module ShopothRider
  module V1
    class ReturnOrders < ShopothRider::Base
      resource 'return' do
        desc 'Return Request list.'
        get 'request_list' do
          status_list = %w(initiated in_partner in_transit delivered_to_dh)
          return_orders = @current_rider.return_customer_orders.where(return_status: status_list).
            includes(customer_order: [:customer, { shipping_address: %i(district thana area) }])
          present return_orders.order(created_at: :asc), with: ShopothRider::V1::Entities::ReturnCustomerOrders
        rescue StandardError => error
          error! respond_with_json("Unable to find return_orders due to #{error}", HTTP_CODE[:NOT_FOUND])
        end

        desc 'Fetch Order Payment History'
        get 'history' do
          return_orders = @current_rider.return_customer_orders
          return [] unless return_orders.present?

          status = %w(in_partner in_transit delivered_to_dh)
          selected_orders = return_orders.where(return_status: status)
          prepare_return_history(selected_orders)
        rescue StandardError => ex
          error! respond_with_json("Unable to fetch return history due to #{ex.message}",
                                   HTTP_CODE[:NOT_FOUND])
        end

        desc 'Return Order Details'
        params do
          requires :return_id, type: Integer, allow_blank: false
        end
        get 'details' do
          return_item = ReturnCustomerOrder.find(params[:return_id])
          if return_item.present?
            present return_item, with: ShopothRider::V1::Entities::ReturnLineItem
          else
            status :not_found
            { success: false, message: 'Return order not found' }
          end
        rescue StandardError => error
          Rails.logger.info "rider_return_order_details: #{__FILE__ } #{error.message.to_s}"
          error!(respond_with_json("Sorry return order with id: #{params[:return_id]} not found", HTTP_CODE[:NOT_FOUND]),
                 HTTP_CODE[:NOT_FOUND])
        end

        desc 'Collect Return order From Customer.'
        params do
          requires :return_id, type: String
          requires :qr_code, type: String
        end
        post 'scan' do
          return_order = ReturnCustomerOrder.initiated.find_by(id: params[:return_id].to_i)
          unless return_order.present?
            error!(respond_with_json('Return request not found or already refunded', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end
          aggr_return = return_order.aggregate_return
          unless aggr_return.rider_id == @current_rider.id
            error!(respond_with_json('You are not allowed to take this return', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          customer_order = return_order.customer_order
          if customer_order.present? && return_order.shopoth_line_item.qr_codes[0] == params[:qr_code]
            ActiveRecord::Base.transaction do
              price = return_order.aggregate_return.sub_total
              pick_up_charge = Configuration.return_pick_up_charge('from_home')
              if price < pick_up_charge
                error!(respond_with_json("Price of items is less than #{pick_up_charge}tk, please contact with customer care",
                                         HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
              return_order.update!(return_status: :in_transit, changeable: @current_rider)
              return_order.update_inventory_and_stock_changes('return_in_transit_quantity')

              if return_order.unpacked?
                customer_order.distributor_margin.deduct(return_order.shopoth_line_item)
                return_order.calculate_coupon_amount if aggr_return.return_customer_orders.initiated.count.zero?
              end
            end
            status :ok
            { success: true, message: 'Successfully return order received' }
          else
            status :not_found
            { success: false, message: 'Return order not in initiated or rider not match' }
          end
        rescue StandardError => error
          Rails.logger.info "rider-return in transit failed: #{error.message}"
          error!(respond_with_json('Sorry! Return order can not be taken to in transit',
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end
      end
    end
  end
end
