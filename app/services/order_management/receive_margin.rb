module OrderManagement
  class ReceiveMargin
    include Interactor
    delegate :orders,
             :params,
             :start_date,
             :end_date,
             :partner,
             :total_orders,
             to: :context
    def call
      context.partner = context.orders.first.partner
      context.start_date = start_date
      context.end_date = end_date
      context.total_orders = calculate_total_orders
      context.fail!(error: 'nothing to receive') unless context.total_orders.present?
      margin_received = context.total_orders.map(&:partner_margin).compact.map(&:route_received_at)
      context.fail!(error: 'SR needs to be paid first') if margin_received.blank? || margin_received.any?(nil)
      context.update_margin = update_margin_n_create_payments
    end

    def update_margin_n_create_payments
      context.total_orders.each do |order|
        margin = order&.partner_margin&.margin_amount
        next unless margin.present?
        next if order.partner_margin.partner_received_at.present?

        order.payments.create!(currency_amount: margin,
                               currency_type: 'BDT',
                               status: :successful,
                               form_of_payment: :cash,
                               paymentable: context.partner.route,
                               receiver_id: context.partner.id,
                               receiver_type: context.partner.class.to_s,
                               customer_order_id: order.id)
        order.partner_margin.update!(partner_received_at: Time.now, partner_received_amount: margin)

      rescue => ex
        Rails.logger.info "partner app margin received failed: order_id: #{order.id} reason: #{ex.message}"
        next
      end
    end

    def calculate_total_orders
      context.orders.where(status: completed_or_partial_return).
        joins(:customer_order_status_changes).
        where("customer_order_status_changes.created_at >= ?
        AND customer_order_status_changes.created_at <= ?", "#{context.start_date}", "#{context.end_date}").
        where('customer_order_status_changes.order_status_id = ?', "#{completed_status.id}")
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

    def completed_status
      OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    end

    def completed_or_partial_return
      status = %w(completed partially_returned)
      OrderStatus.fetch_statuses(status)
    end
  end
end
