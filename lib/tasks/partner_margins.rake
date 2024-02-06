require 'csv'
namespace :partner_margins do
  task update: :environment do |t, args|
    start_date = Date.new(2021, 5, 2).to_time.utc.beginning_of_month
    end_date = Time.now.utc.end_of_day
    completed = OrderStatus.getOrderStatus('completed').id
    customer_orders = CustomerOrder.pick_up_point.induced.where('customer_orders.order_status_id = ?', completed).
                      joins(:customer_order_status_changes).
                      where('customer_order_status_changes.created_at BETWEEN ? AND ?', start_date, end_date).
                      where('customer_order_status_changes.order_status_id = ?', completed)
    customer_orders.each do |co|
      voucher_coupon = Coupon.find_by(code: co.coupon_code)
      next if voucher_coupon&.return_customer_order_id.present?

      margin = co.total_price * 0.05
      partner_margin = co.partner_margin
      if partner_margin.present?
        partner_margin.update!(margin_amount: margin.round(2),
                               route_received_at: nil,
                               partner_received_at: nil,
                               route_received_amount: 0,
                               partner_received_amount: 0)
        p "Update partner margin id: #{partner_margin.id}, order_id: #{co.id}"
      end
    rescue => error
      p "margin_update_failed. order_id: #{co.id}, #{error.message}"
    end
  end
end
