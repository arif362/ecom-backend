module SrReports
  class ReceiveMargin
    include Interactor
    delegate :partners,
             :time,
             :partner_orders,
             :total_orders,
             to: :context
    def call
      context.partner_orders = fetch_partner_orders
      context.total_orders = calculate_total_orders
      context.update_margin = update_margin_n_create_payments
    end

    def update_margin_n_create_payments
      context.total_orders&.each do |order|
        route = order.partner.route
        warehouse = route.warehouse
        margin = order.partner_margin&.margin_amount
        next unless margin.present?

        route_receive_at = order.partner_margin.route_received_at
        next if route_receive_at.present?

        dh_payment_received = order.payments.where(paymentable_type: 'Route', receiver_type: 'Staff')
        next unless dh_payment_received.present? || order.online_payment? || order.wallet_payment? || order.bkash_payment? || order.nagad_payment? && order.is_customer_paid

        staff = Staff.find_by(warehouse: warehouse)
        order.payments.create!(currency_amount: margin,
                               currency_type: 'BDT',
                               status: :successful,
                               form_of_payment: :cash,
                               paymentable: staff,
                               receiver_id: route.id,
                               receiver_type: route.class.to_s,
                               customer_order_id: order.id)
        order.partner_margin.update!(route_received_at: Time.now, route_received_amount: margin)

      rescue => ex
        Rails.logger.info "sr app margin received failed: order_id: #{order.id} reason: #{ex.message}"
        next
      end
    end

    def calculate_total_orders
      # context.partner_orders.where(status: completed_status, pay_type: 'cash_on_delivery').select do |order|
      #   current_month_order?(order, context.time)
      # end
      context.partner_orders&.where(status: completed_or_partial_return)&.select do |order|
        current_month_order?(order, context.time)
      end
    end

    def fetch_partner_orders
      if context.partners.is_a?(Partner)
        context.partners.customer_orders
      else
        CustomerOrder.where(partner: context.partners)
      end
    end

    def current_month_order?(order, time)
      month_n_year = time.present? ? time.to_s : Date.today.strftime('%m/%Y')
      completed_at = order.completed_at&.strftime('%m/%Y')
      month_n_year == completed_at.to_s
    end

    def completed_status
      OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    end

    def completed_or_partial_return
      status = %w(completed partially_returned)
      OrderStatus.fetch_statuses(status)
    end
  end
end
