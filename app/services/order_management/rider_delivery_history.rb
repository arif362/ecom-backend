module OrderManagement
  class RiderDeliveryHistory
    include Interactor

    delegate :orders,
             :delivery_history,
             to: :context

    def call
      context.delivery_history = fetch_delivery_history
    end

    def fetch_delivery_history
      delivered_orders = context.orders.select do |order|
        order.status.order_type == 'completed'
      end

      last_5_days_orders(delivered_orders)
    end

    def last_5_days_orders(orders)
      orders.select do |order|
        last_5_days.include?(format_date(order.completed_at))
      end
    end

    def last_5_days
      (4.days.ago.to_date..Date.today).map { |day| day.strftime("%d-%m-%Y") }
    end

    def format_date(date)
      date&.strftime("%d-%m-%Y")
    end
  end
end
