namespace :sr_margin_mismatch do
  desc 'This task fixes SR payments received & route_received_at, route_received_amount entry in partner margin table.'
  task sr_payment_fix: :environment do |t, args|

    Route.all.each do |route|
      aggregated_payments = route.aggregated_payments&.sr_margin

      next unless aggregated_payments.present?

      aggregated_payments.each do |aggregated_payment|
        payment = aggregated_payment.payment
        next if payment.successful?

        payment.successful!
        aggregated_payment.aggregated_payment_customer_orders.each do |a_order|
          partner_margin = a_order.customer_order.partner_margin
          next if partner_margin.partner_received_at.nil?

          partner_margin.update!(route_received_at: (a_order.created_at + 1.hour), route_received_amount: partner_margin.margin_amount)
        end
      end
    end
  end
end
