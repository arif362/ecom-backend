module OrderManagement
  class Statement
    include Interactor
    delegate :orders,
             :filtered_orders,
             :params,
             :start_date,
             :end_date,
             :partner,
             :received_from_sr,
             :delivered_to_customer,
             :total_payment,
             :customer_paid,
             :paid_to_sr,
             :remaining_payment,
             :total_return_orders,
             :packed_return,
             :unpacked_return,
             :delivered_packed,
             :delivered_unpacked,
             :expired_orders,
             :response_hash,
             to: :context

    def call
      context.partner = context.orders.first.partner
      context.start_date = start_date
      context.end_date = end_date
      context.received_from_sr = calculate_received_from_sr
      context.delivered_to_customer = calculate_delivered_to_customer
      context.total_payment = calculate_total_payment
      context.customer_paid = calculate_customer_paid
      context.paid_to_sr = calculate_paid_to_sr
      context.remaining_payment = context.customer_paid - context.paid_to_sr
      context.total_return_orders = fetch_total_return_orders
      context.packed_return = calculate_packed_return_orders
      context.unpacked_return = calculate_unpacked_return_orders
      context.delivered_packed = calculate_delivered_packed
      context.delivered_unpacked = calculate_delivered_unpacked
      context.expired_orders = calculate_expired_orders
      context.response_hash = prepare_response_hash
    end

    def calculate_received_from_sr
      context.orders.joins(:customer_order_status_changes).where("customer_order_status_changes.created_at >= ? AND customer_order_status_changes.created_at <= ?", "#{context.start_date}", "#{context.end_date}").
        where("customer_order_status_changes.order_status_id = ?", "#{delivered_to_partner_status.id}")
    end

    def calculate_delivered_to_customer
      context.orders.joins(:customer_order_status_changes).where("customer_order_status_changes.created_at >= ? AND customer_order_status_changes.created_at <= ?", "#{context.start_date}", "#{context.end_date}").
        where("customer_order_status_changes.order_status_id = ?", "#{delivered_to_customer_status.id}")
    end

    def calculate_total_payment
      context.received_from_sr.where(pay_type: 'cash_on_delivery').map(&:total_price).sum
    end

    def calculate_customer_paid
      context.received_from_sr.map do |order|
        if %w(customer_paid partner_paid).include?(order.pay_status) && order.pay_type == 'cash_on_delivery'
          order.total_price
        end
      end.compact.sum
    end

    def calculate_paid_to_sr
      context.received_from_sr.map do |order|
        order.total_price if order.pay_status == 'partner_paid' && order.pay_type == 'cash_on_delivery'
      end.compact.sum
    end

    def fetch_total_return_orders
      context.partner.return_customer_orders.joins(:return_status_changes).where("return_status_changes.created_at >= ? AND return_status_changes.created_at <= ?", "#{context.start_date}", "#{context.end_date}").
        where("return_status_changes.status = 'in_partner'")
    end

    def calculate_packed_return_orders
      context.total_return_orders.select(&:packed?)
    end

    def calculate_unpacked_return_orders
      context.total_return_orders.select(&:unpacked?)
    end

    def calculate_delivered_packed
      context.packed_return.select { |return_order| return_order.return_status_changes.find_by(status: 'in_transit') }
    end

    def calculate_delivered_unpacked
      context.unpacked_return.select { |return_order| return_order.return_status_changes.find_by(status: 'in_transit') }
    end

    def calculate_expired_orders
      context.orders.where(status: delivered_to_partner_status, pay_status: 'extension_expired')
    end

    def delivered_to_partner_status
      OrderStatus.find_by(order_type: 'delivered_to_partner')
    end

    def delivered_to_customer_status
      OrderStatus.find_by(order_type: 'completed')
    end

    def start_date
      date = context.params[:start_date].to_s
      start_date = if date.present?
                     Date.parse(date).to_time.in_time_zone('Dhaka')
                   else
                     Time.now.in_time_zone('Dhaka').beginning_of_month
                   end
      start_date.beginning_of_day
    end

    def end_date
      date = context.params[:end_date].to_s
      end_date = if date.present?
                   Date.parse(date).to_time.in_time_zone('Dhaka')
                 else
                   Time.now.in_time_zone('Dhaka')
                 end
      end_date.end_of_day
    end

    def prepare_response_hash
      {
        received_from_sr: context.received_from_sr.count.to_s,
        delivered_to_customer: context.delivered_to_customer.count.to_s,
        delivery_remaining: (context.received_from_sr.count - context.delivered_to_customer.count).to_s,
        total_payment: context.total_payment.to_s,
        customer_paid: context.customer_paid.to_s,
        paid_to_sr: context.paid_to_sr.to_s,
        remaining_payment: context.remaining_payment.to_s,
        total_returns: (context.unpacked_return&.count.to_i + context.packed_return&.count.to_i).to_s,
        unpacked: "#{context.delivered_unpacked&.count.to_i} / #{context.unpacked_return&.count.to_i}",
        packed: "#{context.delivered_packed&.count.to_i} / #{context.packed_return&.count.to_i}",
        expired_orders: context.expired_orders.count.to_s,
      }
    end
  end
end
