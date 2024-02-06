module SrReports
  class GenerateReport
    include Interactor

    delegate :partners,
             :partner_orders,
             :total_orders,
             :recieved_from_dh,
             :delivered,
             :total_payment,
             :customer_paid,
             :collected_amount,
             :remaining_amount,
             :partner_return_orders,
             :packed_return,
             :unpacked_return,
             :report_hash,
             :expired_orders,
             to: :context

    def call
      context.partner_orders = fetch_partner_orders
      context.total_orders = calculate_total_orders
      context.recieved_from_dh = calculate_intransit_orders
      context.delivered = calculate_delivered_orders
      context.dh_received = calculate_dh_received
      context.total_payment = calculate_total_payment
      context.customer_paid = calculate_customer_paid
      context.collected_amount = calculate_collected_amount
      context.remaining_amount = context.customer_paid&.to_f&.- context.collected_amount&.to_f
      context.partner_return_orders = fetch_partner_return_orders
      context.packed_return = calculate_packed_return_orders
      context.unpacked_return = calculate_unpacked_return_orders
      context.received_packed = calculate_received_packed
      context.received_unpacked = calculate_received_unpacked
      context.expired_orders = calculate_expired_orders
      context.report_hash = generate_report_hash
    end

    def calculate_total_orders
      instransit_orders = calculate_intransit_orders
      ready_to_shipment_orders = calculate_ready_to_shipment_orders
      instransit_orders + ready_to_shipment_orders
    end

    def calculate_intransit_orders
      context.partner_orders.select do |order|
        order_status_change = order.customer_order_status_changes.find_by(order_status: instransit_status)
        next unless order_status_change.present?

        format_time(Time.now) == format_time(order_status_change.created_at)
      end
    end

    def calculate_ready_to_shipment_orders
      context.partner_orders.where(status: ready_to_shipment_status)
    end

    def calculate_delivered_orders
      context.partner_orders.select do |order|
        order_status_change = order.customer_order_status_changes.find_by(order_status: delivered_order_status)
        next unless order_status_change.present?

        format_time(Time.now) == format_time(order_status_change.created_at)
      end
    end

    def fetch_partner_return_orders
      if context.partners.is_a?(Partner)
        context.partners.return_customer_orders
      else
        ReturnCustomerOrder.where(partner: context.partners)
      end
    end

    def fetch_partner_orders
      if context.partners.is_a?(Partner)
        context.partners.customer_orders
      else
        CustomerOrder.where(partner: context.partners)
      end
    end

    def calculate_total_payment
      context.partner_orders.where(status: total_payment_status, pay_type: 'cash_on_delivery').sum(&:total_price).to_f
    end

    def calculate_dh_received
      @calculate_dh_received ||= context.partner_orders.where(pay_status: 'dh_received', pay_type: 'cash_on_delivery').sum(&:total_price).to_f
    end

    def calculate_dh_received
      @calculate_dh_received ||= context.partner_orders.where(pay_status: 'dh_received').sum(&:total_price).to_f
    end

    def calculate_customer_paid
      context.partner_orders.where(pay_status: %w[customer_paid partner_paid], pay_type: 'cash_on_delivery').sum(&:total_price).to_f
    end

    def calculate_collected_amount
      context.partner_orders.where(pay_status: 'partner_paid', pay_type: 'cash_on_delivery').sum(&:total_price).to_f
    end

    def instransit_status
      OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit])
    end

    def delivered_order_status
      OrderStatus.getOrderStatus(OrderStatus.order_types[:delivered_to_partner])
    end

    def customer_paid_status
      OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    end

    def ready_to_shipment_status
      OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment])
    end

    def total_payment_status
      [OrderStatus.getOrderStatus(OrderStatus.order_types[:delivered_to_partner]),
       OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]),]
    end

    def format_time(date)
      date.strftime('%d/%m/%y')
    end

    def calculate_packed_return_orders
      context.partner_return_orders.where(return_type: 'packed', return_status: %w(in_partner in_transit))
    end

    def calculate_unpacked_return_orders
      context.partner_return_orders.where(return_type: 'unpacked', return_status: %w(in_partner in_transit))
    end

    def calculate_received_packed
      context.partner_return_orders.where(return_type: 'packed', return_status: 'in_transit')
    end

    def calculate_received_unpacked
      context.partner_return_orders.where(return_type: 'unpacked', return_status: 'in_transit')
    end

    def calculate_expired_orders
      context.partner_orders.where(status: delivered_order_status, pay_status: 'extension_expired')
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
          total_order: context.total_payment.to_f,
          customer_paid: context.customer_paid.to_f,
          collected: context.collected_amount.to_f,
          remaining: context.remaining_amount.to_f.abs,
        },
        returns: {
          total: context.packed_return&.count.to_i + context.unpacked_return&.count.to_i,
          unpacked: context.unpacked_return&.count.to_i,
          packed: context.packed_return&.count.to_i,
          expired_orders: context.expired_orders&.count.to_i,
          packed_collected: calculate_received_packed&.count.to_i,
          unpacked_collected: calculate_received_unpacked&.count.to_i,
          total_collected: calculate_received_packed&.count.to_i + calculate_received_unpacked&.count.to_i,
        },
      }
    end
  end
end
