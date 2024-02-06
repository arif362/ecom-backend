module SrReports
  class GeneratePayout
    include Interactor
    delegate :partners,
             :time,
             :current_route_device,
             :partner_orders,
             :total_orders,
             :induced_orders,
             :organic_orders,
             :induced_margin,
             :organic_margin,
             :total_margin,
             :paid_to_partner,
             :remaining_amount,
             :received_from_fc,
             :payout_hash,
             to: :context
    def call
      context.partner_orders = fetch_partner_orders
      context.total_orders = calculate_total_orders
      context.induced_orders = fetch_induced_orders
      context.induced_margin = calculate_induced_margin
      context.organic_orders = fetch_organic_orders
      context.organic_margin = calculate_organic_margin
      context.total_margin = calculate_total_margin
      context.paid_to_partner = calculate_paid_to_partner
      context.received_from_fc = calculate_received_from_fc
      context.remaining_amount = calculate_remaining_amount
      context.payout_hash = process_payout_hash
    end

    def calculate_total_orders
      # context.partner_orders.where(status: completed_status, pay_type: 'cash_on_delivery').select do |order|
      #   current_month_order?(order, context.time)
      # end
      context.partner_orders.where(status: completed_or_partial_return).select do |order|
        current_month_order?(order, context.time)
      end
    end

    def fetch_induced_orders
      context.total_orders.select(&:induced?)
    end

    def fetch_organic_orders
      context.total_orders.select(&:organic?)
    end

    def calculate_induced_margin
      context.induced_orders.map do |order|
        order&.partner_margin&.margin_amount || induce_margin_calculate(order)
      end.compact.sum

    end

    def induce_margin_calculate(order)
      if order.return_coupon?
        order.cart_total_price * 0.05
      else
        order.total_price * 0.05
      end
    end

    def calculate_organic_margin
      context.organic_orders.map do |order|
        order&.partner_margin&.margin_amount || 15
      end.compact.sum
    end

    def calculate_paid_to_partner
      context.total_orders.map do |order|
        margin = order&.partner_margin
        margin&.partner_received_amount
      end.compact.sum
    end

    def calculate_total_margin
      total_margin = context.total_orders.map do |order|
        order&.partner_margin&.margin_amount
      end.compact.sum
      total_margin.zero? ? context.induced_margin + context.organic_margin : total_margin
    end

    def calculate_received_from_fc
      context.total_orders.map do |order|
        margin = order&.partner_margin
        margin&.route_received_amount #|| manual_margin(order)
      end.compact.sum
    end

    def manual_margin(order)
      if order.induced?
        if order.return_coupon?
          order.cart_total_price * 0.05
        else
          order.total_price * 0.05
        end
      else
        15
      end
    end

    def calculate_remaining_amount
      context.total_margin - context.paid_to_partner
    end

    def completed_status
      OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    end

    def completed_or_partial_return
      status = %w(completed partially_returned)
      OrderStatus.fetch_statuses(status)
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

    def process_payout_hash
      # induced holding fee 5 means 5%
      {
        total_orders: context.total_orders.count,
        organic_orders: context.organic_orders.count,
        induced_orders: context.induced_orders.count,
        organic_margin: context.organic_margin.round(2),
        induced_margin: context.induced_margin.round(2),
        total_margin: context.total_margin.round(2),
        received_from_fc: context.received_from_fc.round(2),
        paid_to_partner: context.paid_to_partner.round(2),
        remaining_payout: context.remaining_amount.round(2),
        organic_holding_fee: '15',
        induced_holding_fee: '5',
      }
    end
  end
end
