module OrderManagement
  class GenerateRiderReport
    include Interactor

    delegate :orders,
             :start_date,
             :end_date,
             :total_orders,
             :recieved_from_dh,
             :delivered,
             :rider,
             :customer_paid,
             :online_collected_amount,
             :cod_collected_amount,
             :dh_received,
             :rider_return_orders,
             :total_returns,
             :return_received,
             :remaining_return,
             :report_hash,
             to: :context

    def call
      context.rider = context.orders.first.rider
      context.start_date = start_date
      context.end_date = end_date
      context.total_orders = calculate_total_orders
      context.recieved_from_dh = calculate_intransit_orders
      context.delivered = calculate_delivered_orders
      context.customer_paid = calculate_customer_paid
      context.online_collected_amount = calculate_online_collected_amount
      context.cod_collected_amount = calculate_cod_collected_amount
      context.dh_received = calculate_dh_received
      context.rider_return_orders = fetch_rider_return_orders
      context.total_returns = calculate_total_returns.count
      context.return_received = calculate_return_received.count
      context.remaining_return = context.total_returns - context.return_received
      context.report_hash = generate_report_hash
    end

    def calculate_total_orders
      instransit_orders = calculate_intransit_orders
      ready_to_shipment_orders = calculate_ready_to_shipment_orders
      instransit_orders + ready_to_shipment_orders
    end

    def calculate_intransit_orders
      context.orders.joins(:customer_order_status_changes).where("customer_order_status_changes.created_at >= ? AND customer_order_status_changes.created_at <= ?", "#{context.start_date}", "#{context.end_date}").
        where("customer_order_status_changes.order_status_id = ?", "#{instransit_status.id}")
    end

    def calculate_ready_to_shipment_orders
      context.orders.where(status: ready_to_shipment_status)
    end

    def calculate_delivered_orders
      context.orders.joins(:customer_order_status_changes).where("customer_order_status_changes.created_at >= ? AND customer_order_status_changes.created_at <= ?", "#{context.start_date}", "#{context.end_date}").
        where("customer_order_status_changes.order_status_id = ?", "#{rider_delivered_status.id}")
    end

    def fetch_rider_return_orders
      context.rider.return_customer_orders
    end

    def calculate_customer_paid
      context.delivered.map(&:total_price).sum.to_f
    end

    def calculate_online_collected_amount
      context.delivered.where.not(pay_type: 'cash_on_delivery').map(&:total_price).sum.to_f
    end

    def calculate_cod_collected_amount
      context.customer_paid - context.online_collected_amount
    end

    def calculate_dh_received
      staff = context.rider.warehouse.staffs.first
      payments = Payment.where(status: 'successful',
                               paymentable: context.rider,
                               receiver_id: staff.id,
                               receiver_type: staff.class.to_s)
      payments.select do |payment|
        format_time(payment.created_at) == format_time(Time.now)
      end.map(&:currency_amount).sum
    end

    def calculate_total_returns
      initiated_returns = calculate_initiated_returns
      in_transit_returns = calculate_return_received
      initiated_returns + in_transit_returns
    end

    def calculate_initiated_returns
      context.rider_return_orders.where('return_customer_orders.created_at BETWEEN ? AND ?', context.start_date.to_s, context.end_date.to_s).
        where('return_customer_orders.return_status = ?', 0)
    end

    def calculate_return_received
      context.rider_return_orders.joins(:return_status_changes).where('return_customer_orders.created_at BETWEEN ? AND ?', context.start_date.to_s, context.end_date.to_s).
        where('return_status_changes.status = ?', 'in_transit')
    end

    def instransit_status
      OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit])
    end

    def rider_delivered_status
      OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    end

    def ready_to_shipment_status
      OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment])
    end

    def start_date
      Time.now.in_time_zone('Dhaka').beginning_of_day
    end

    def end_date
      Time.now.in_time_zone('Dhaka').end_of_day
    end

    def format_time(date)
      date.strftime('%d/%m/%y')
    end

    def generate_report_hash
      {
        delivery: {
          total_order: context.total_orders&.count.to_i,
          received_from_dh: context.recieved_from_dh&.count.to_i,
          delivered: context.delivered&.count.to_i,
          remaining: (context.recieved_from_dh&.count.to_i - context.delivered&.count.to_i)&.abs,
        },
        payments: {
          customer_paid: context.customer_paid.to_f,
          collected_online: context.online_collected_amount.to_f,
          collected_cod: context.cod_collected_amount,
          paid_to_fc: context.dh_received.to_f,
        },
        returns: {
          total_requests: context.total_returns,
          received_from_customer: context.return_received,
          remaining: context.remaining_return,
        },
      }
    end
  end
end
