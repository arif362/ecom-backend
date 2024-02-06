namespace :route do
  desc 'This task creates notification for SR'
  task app_notification: :environment do |t, args|
    Route.all.each do |route|
      count = 0
      route.partners.each do |partner|
        next unless schedule_today?(partner)

        ready_orders = partner.customer_orders
                         .where(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment])).count
        partner.app_notifications.create(message: "You will receive #{ready_orders} orders today") if ready_orders > 0
        count += ready_orders
      end

      if count > 0
        route.app_notifications.create(message: "You have #{count} orders to deliver",
                                       title: 'Order Delivery')
      end
    end
  rescue => ex
    puts "--- Error configuring route notification due to: #{ex}"
  end

  private

  def schedule_today?(partner)
    partner_schedule = partner.schedule
    current_day = Date.today.strftime("%A")[0..2].downcase
    partner_schedule.include?(current_day)
  end
end
