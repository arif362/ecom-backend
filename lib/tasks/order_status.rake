namespace :order_statuses do
  desc 'create order status'
  task create_order_status: :environment do |t, args|
    order_statuses = OrderStatus.order_types

    order_statuses.each_with_index do |order_status, index|
      system_order_status = ''
      customer_order_status = ''
      admin_order_status = ''
      sales_representative_order_status = ''
      partner_order_status = ''
      case order_status[0]
      when 'returned_from_partner'
        customer_order_status = 'Cancelled'
      when 'in_transit_delivery_switch'
        customer_order_status = 'Ready to Ship'
      when 'delivered_to_partner'
        customer_order_status = 'Delivered to Outlet'
      when 'packed_cancelled'
        customer_order_status = 'Cancelled'
        sales_representative_order_status = 'Cancelled'
        partner_order_status = 'Cancelled'
      when 'completed', 'returned_from_customer'
        customer_order_status = 'Delivered'
      when 'order_confirmed'
        customer_order_status = 'Confirmed'
        admin_order_status = 'Confirmed'
        sales_representative_order_status = 'Confirmed'
        partner_order_status = 'Confirmed'
      when 'sold_to_partner'
        customer_order_status = 'Cancelled'
        partner_order_status = 'Completed'
      when 'in_transit_reschedule'
        customer_order_status = 'Rescheduled'
        sales_representative_order_status = 'Rescheduled'
        partner_order_status = 'Rescheduled'
      when 'ready_to_shipment'
        customer_order_status = 'Processing'
        admin_order_status = 'Ready to Ship'
        sales_representative_order_status = 'Ready to Ship'
        partner_order_status = 'Ready to Ship'
      when 'in_transit', 'on_hold'
        customer_order_status = 'On the Way'
      when 'in_transit_partner_switch'
        customer_order_status = 'In Transit'
      when 'ready_to_ship_from_fc', 'in_transit_to_dh'
        customer_order_status = 'Processing'
      when 'in_transit_cancelled'
        system_order_status = 'Cancelled'
        customer_order_status = 'Cancelled'
        sales_representative_order_status = 'Cancelled'
        partner_order_status = 'Cancelled'
      else
        system_order_status = system_order_status.empty? ? order_status[0].titleize : system_order_status
        customer_order_status = customer_order_status.empty? ? order_status[0].titleize : customer_order_status
        admin_order_status = admin_order_status.empty? ? order_status[0].titleize : admin_order_status
        sales_representative_order_status = sales_representative_order_status.empty? ? order_status[0].titleize : sales_representative_order_status
        partner_order_status = partner_order_status.empty? ? order_status[0].titleize : partner_order_status
      end

      case order_status[0]
      when 'partially_returned', 'completed', 'returned_from_customer'
        bn_customer_order_status = 'ডেলিভারী করা হয়েছে'
      when 'returned_from_partner', 'cancelled', 'cancelled_at_dh', 'sold_to_partner', 'in_transit_cancelled', 'cancelled_at_in_transit_to_fc', 'cancelled_at_in_transit_to_dh'
        bn_customer_order_status = 'ক্যান্সেল করা হয়েছে'
      when 'in_transit_delivery_switch', 'in_transit_reschedule', 'in_transit', 'in_transit_partner_switch', 'on_hold'
        bn_customer_order_status = 'যাত্রাপথে আছে'
      when 'delivered_to_partner'
        bn_customer_order_status = 'দোকানে পৌঁছে গিয়েছে'
      when 'order_placed'
        bn_customer_order_status = 'অর্ডার প্লেস হয়েছে'
      when 'ready_to_shipment'
        bn_customer_order_status = 'পাঠানোর জন্য প্রস্তুত'
      else
        bn_customer_order_status = ''
      end
      OrderStatus.find_or_create_by(order_type: order_status[0]) do |order|
        order.system_order_status = system_order_status
        order.customer_order_status = customer_order_status
        order.admin_order_status = admin_order_status
        order.sales_representative_order_status = sales_representative_order_status
        order.partner_order_status = partner_order_status
        order.bn_customer_order_status = bn_customer_order_status
      end
    rescue StandardError => error
      Rails.logger.info error.full_message.to_s
      puts "Error occurred in row number: #{index}, error: #{error.full_message}"
    end
  end
end
