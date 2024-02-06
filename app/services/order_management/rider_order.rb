module OrderManagement
  class RiderOrder
    include Interactor

    VALID_STATUS = %w(ready_to_shipment in_transit on_hold)
    TODAY_STATUS = %w(completed cancelled)
    delegate :orders, :rider,
             :home_delivery_orders,
             :express_delivery_orders,
             :return_orders,
             :count_hash,
             :balance,
             to: :context

    def call
      context.home_delivery_orders = filter_home_delivery_orders
      context.express_delivery_orders = filter_express_delivery_orders
      context.return_orders = filter_return_orders
      context.balance = calculate_balance
      context.count_hash = process_count_hash
    end

    def filter_home_delivery_orders
      home_delivery_orders = context.orders.where(shipping_type: 0)
      orders = home_delivery_orders.select do |order|
        VALID_STATUS.include?(order.status.order_type)
      end

      today_orders = home_delivery_orders.select do |order|
        TODAY_STATUS.include?(order.status.order_type) && format_time(order.completed_at) == format_time(Time.now)
      end

      on_hold_orders = orders.select do |order|
        order.status.order_type == 'on_hold'
      end

      total_orders = orders << today_orders
      process_order_hash(total_orders.flatten, on_hold_orders)
    end

    def filter_express_delivery_orders
      exp_delivery_orders = context.orders.where(shipping_type: 1)
      orders = exp_delivery_orders.select do |order|
        VALID_STATUS.include?(order.status&.order_type)
      end

      today_orders = exp_delivery_orders.select do |order|
        TODAY_STATUS.include?(order.status.order_type) && format_time(order.completed_at) == format_time(Time.now)
      end

      on_hold_orders = orders.select do |order|
        order.status.order_type == 'on_hold'
      end

      total_orders = orders << today_orders
      process_order_hash(total_orders.flatten, on_hold_orders)
    end

    def filter_return_orders
      status_list = %w(initiated)
      return_orders =
        context&.rider&.return_customer_orders&.select do |order|
          status_list.include?(order.return_status.to_s)
        end
      process_order_hash(return_orders, [])
    end

    def calculate_balance
      customer_orders = orders.joins(:payments).where(
        "payments.paymentable_type = 'User' AND payments.receiver_type = 'Rider'",
      )
      cash_balance = 0.0
      customer_orders.each do |order|
        if order.payments.find_by(receiver_type: 'Staff').nil?
          cash_balance += order.payments.find_by(paymentable_type: 'User', receiver_type: 'Rider')&.currency_amount || 0
        end
      end
      { cash_balance: cash_balance.to_d.round(2) }
    end

    def process_order_hash(orders, on_hold_orders)
      {
        total_orders: orders.count,
        on_hold_orders: on_hold_orders.count,
      }
    end

    def format_time(time)
      time&.strftime("%m/%d/%Y")
    end

    def process_count_hash
      {
        balance: context.balance,
        home_deliveries: context.home_delivery_orders,
        express_deliveries: context.express_delivery_orders,
        return_deliveries: context.return_orders,
      }
    end
  end
end
