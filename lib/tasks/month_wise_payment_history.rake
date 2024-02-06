namespace :month_wise_payment_history do
  desc 'This task creates Month wish payment history for Finance.'
  task create: :environment do |t, args|
    puts "---\n Rake task run for date and payment history"
    start_date_time = (Time.now - 1.month).beginning_of_month
    end_date_time = (Time.now - 1.month).end_of_month
    date_range = start_date_time..end_date_time
    month = (Time.now - 1.month).strftime('%m')
    year = (Time.now - 1.month).strftime('%Y')
    completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    index = 0
    Distributor.all.each do |distributor|
      orders = distributor.customer_orders.joins(:customer_order_status_changes).where(
        customer_order_status_changes: { order_status: completed_status, created_at: date_range },
      )
      total_collection = orders.joins(:payments).where(
        payments: { paymentable_type: %w(Route Rider), receiver_type: 'Staff' },
      ).sum(:currency_amount)

      partner_commission = 0
      return_amount = 0
      payable_amount = orders.sum(:total_price)
      agent_commission = if distributor.is_commission_applicable
                           orders.joins(:distributor_margin).sum(:amount).round(2) || 0
                         end

      orders.where(partner_id: distributor.partners.ids).group_by(&:partner_id).each do |partner_id, orders|
        orders.each do |order|
          if order.induced? || (order.organic? && order.pick_up_point?)
            p "Sub-agent commission for: #{order.id} is: #{order.partner_margin&.margin_amount}"
            partner_commission += order.partner_margin&.margin_amount
          end
        end
        partner_commission = partner_commission.round(2)
      end

      ReturnCustomerOrder.where(customer_order: orders).each do |return_order|
        return_amount += return_order.shopoth_line_item.effective_unit_price
      end

      payment_history = distributor.month_wise_payment_histories.find_or_create_by!(month: "#{year}-#{month}")

      payment_history.update!(
        total_collection: total_collection.ceil,
        agent_commission: agent_commission,
        partner_commission: partner_commission,
        payable_amount: payable_amount,
        return_amount: return_amount.ceil,
      )
      p "#{index + 1}: MonthWisePaymentHistory created successfully for distributor id: #{distributor.id}"
    end
  rescue StandardError => error
    puts "--- Error on MonthWisePaymentHistory creation due to: #{error}"
  end
end
