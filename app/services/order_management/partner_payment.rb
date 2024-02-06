module OrderManagement
  class PartnerPayment
    include Interactor
    delegate :orders,
             :filtered_orders,
             :params,
             :start_date,
             :end_date,
             :total_orders,
             :induced_orders,
             :induced_margin,
             :organic_orders,
             :organic_margin,
             :total_margin,
             :received_from_sr,
             :payout_hash,
             to: :context
    def call
      context.start_date = start_date
      context.end_date = end_date
      context.total_orders = calculate_total_orders
      context.induced_orders = fetch_induced_orders
      context.induced_margin = calculate_induced_margin
      context.organic_orders = fetch_organic_orders
      context.organic_margin = calculate_organic_margin
      context.total_margin = calculate_total_margin
      context.received_from_sr = calculate_received_from_sr
      context.payout_hash = process_payout_hash
    end

    def calculate_total_orders
      context.orders.where(status: completed_or_partial_return, completed_at: context.start_date..context.end_date)
    end

    def fetch_induced_orders
      context.total_orders.select(&:induced?)
    end

    def fetch_organic_orders
      context.total_orders.select(&:organic?)
    end

    def calculate_induced_margin
      context.induced_orders.map do |order|
        order&.partner_margin&.margin_amount
      end.compact.sum
    end

    def calculate_organic_margin
      context.organic_orders.map do |order|
        order&.partner_margin&.margin_amount
      end.compact.sum
    end

    def calculate_received_from_sr
      context.total_orders.map do |order|
        margin = order&.partner_margin
        margin&.partner_received_amount
      end.compact.sum
    end

    def calculate_total_margin
      context.induced_margin + context.organic_margin
    end

    def completed_status
      OrderStatus.find_by(order_type: 'completed')
    end

    def completed_or_partial_return
      status = %w(completed partially_returned)
      OrderStatus.fetch_statuses(status)
    end

    def start_date
      month = context.params[:month]
      year = context.params[:year]
      start_date = if month.present? && year.present?
                     DateTime.civil(year, month, 1).in_time_zone('Dhaka')
                   else
                     DateTime.now.beginning_of_month
                   end
      start_date.beginning_of_day
    end

    def end_date
      month = context.params[:month]
      year = context.params[:year]
      end_date = if month.present? && year.present?
                   DateTime.civil(year, month, -1).in_time_zone('Dhaka')
                 else
                   DateTime.now.end_of_month
                 end
      end_date.end_of_day
    end

    def process_payout_hash
      {
        total_orders: context.total_orders.count.to_s,
        organic_orders: "#{context.organic_orders.count} (TK. #{context.organic_margin.round(2)})",
        induced_orders: "#{context.induced_orders.count} (TK. #{context.induced_margin.round(2)})",
        total_margin: context.total_margin.round(2).to_s,
        received_from_sr: context.received_from_sr.round(2).to_s,
        organic_holding_fee: '15',
        induced_holding_fee: '5',
      }
    end
  end
end
