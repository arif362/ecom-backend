module ShopothWarehouse
  module V1
    class RouteReturns < ShopothWarehouse::Base
      helpers do
        def change_status_n_create_payments(customer_orders, route, staff)
          customer_orders.each do |customer_order|
            customer_order.update!(pay_status: 'dh_received')
            customer_order.payments.create!(currency_amount: customer_order.total_price,
                                            currency_type: 'BDT',
                                            status: :successful,
                                            customer_order_id: customer_order.id,
                                            paymentable: route,
                                            receiver_id: staff.id,
                                            receiver_type: staff.class.to_s)
          end
        end
      end
      resource :route_returns do
        desc 'Route details with returns'
        get '/details' do
          params do
            requires :route_id, type: Integer
          end
          route = Route.find(params[:route_id])

          if @current_staff.warehouse.routes.include?(route)
            present route, with: ShopothWarehouse::V1::Entities::RouteDeviceDetails
          else
            error! respond_with_json('Route not found in Warehouse', HTTP_CODE[:NOT_FOUND])
          end
        rescue => error
          error! respond_with_json("Failed : #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Collect Money from SR'
        post 'collect_money' do
          params do
            requires :route_id, type: Integer
            requires :money_type, type: String
          end
          route = Route.find(params[:route_id])

          if @current_staff.warehouse.routes.include?(route)
            warehouse = @current_staff.warehouse
            case params[:money_type]
            when 'cash'
              warehouse.update(collected_cash_from_routes: (warehouse.collected_cash_from_routes + route.cash_amount))
              route.update(cash_amount: 0)
            when 'wallet'
              warehouse.create_wallet(currency_amount: 0.0, currency_type: 'Tk.') if @current_staff.warehouse.wallet.nil?
              warehouse.wallet.update(currency_amount: (warehouse.wallet.currency_amount + route.wallet.currency_amount))
              route.wallet.update(currency_amount: 0)
            end
            customer_orders = CustomerOrder.joins(:partner).where('partners.route_id = ? AND customer_orders.pay_status = ?', route.id, 2)
            change_status_n_create_payments(customer_orders, route, @current_staff)
            respond_with_json('Money collected', HTTP_CODE[:OK])
          else
            error! respond_with_json('Route not found in Warehouse', HTTP_CODE[:NOT_FOUND])
          end
        rescue => error
          error! respond_with_json("Failed : #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Receive return request from SR.'
        put 'receive_order' do
          params do
            requires :return_id, type: Integer
          end
          return_order = ReturnCustomerOrder.find(params[:return_id])

          if return_order.in_transit?
            warehouse = return_order.customer_order.warehouse
            return_order.update!(return_status: :qc_pending, qc_status: :pending, changeable: @current_staff)
            warehouse.update(return_count: (warehouse.return_count.to_i + 1))
            status :ok
            respond_with_json('Return Order Received', HTTP_CODE[:OK])
          else
            error! respond_with_json('Return Order can not be received.', HTTP_CODE[:OK])
          end
        rescue => error
          error! respond_with_json("Failed : #{error}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
