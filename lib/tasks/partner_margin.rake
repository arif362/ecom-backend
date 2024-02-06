namespace :partner_margin do
  desc 'Script for warehouse margin create.'
  task create: :environment do |_t, _args|
    completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    partial_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
    skip_partner_margin = []
    CustomerOrder.where(status: completed_status).each do |order|
      if order.induced?
        amount = order.return_coupon == true ? (order.cart_total_price * 0.05) : (order.total_price * 0.05)
        PartnerMargin.find_or_create_by(partner_id: order.partner_id, customer_order: order, order_type: order.order_type, margin_amount: amount)
      elsif order.organic? && order.pick_up_point?
        PartnerMargin.find_or_create_by(partner_id: order.partner_id, customer_order: order, order_type: order.order_type, margin_amount: 15)
      else
        skip_partner_margin << order.id
      end
    end

    CustomerOrder.where(status: partial_status).each do |order|
      if order.organic? && order.pick_up_point? && order.return_all_unpacked_items?
        PartnerMargin.find_or_create_by(partner_id: order.partner_id, customer_order: order, order_type: order.order_type, margin_amount: 0)
      elsif order.organic? && order.pick_up_point?
        PartnerMargin.find_or_create_by(partner_id: order.partner_id, customer_order: order, order_type: order.order_type, margin_amount: 15)
      elsif order.induced?
        amount = order.return_coupon == true ? (order.cart_total_price * 0.05) : (order.total_price * 0.05)
        order.return_customer_orders.each do |return_order|
          line_item = return_order.shopoth_line_item
          price = (line_item.sub_total / line_item.quantity) || 0
          amount = (amount - (price * 0.05)).negative? ? 0 : (amount - (price * 0.05))
        end
        PartnerMargin.find_or_create_by(partner_id: order.partner_id, customer_order: order, order_type: order.order_type, margin_amount: amount)
      else
        skip_partner_margin << order.id
      end
    end

    p "Skipped Warehouse Margin creation for customer order: #{skip_partner_margin}"
  end

  desc 'Script for warehouse margin update.'
  task update: :environment do |_t, _args|
    p 'Partner Margin Updating Started'
    completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    partial_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
    skip_partner_margin = []

    # margin issue fixing for without return and promotion coupon applied orders

    CustomerOrder.where(status: completed_status, coupon_code: Coupon.multi_user.map(&:code) + Coupon.first_registration.map(&:code)).each do |order|
      p "Margin updating for customer order: #{order.id}"
      order.update_columns(return_coupon: false)


      if order.home_delivery? || order.express_delivery? || order.partner_id.nil?
        skip_partner_margin << order.id
      else
        amount = PartnerMargin.calculate_margin(order)
        generate_margin(amount, order)
      end
    end

    CustomerOrder.where(status: partial_status, coupon_code: Coupon.multi_user.map(&:code) + Coupon.first_registration.map(&:code)).each do |order|
      p "Margin creating for customer order: #{order.id}"

      if order.organic? && order.pick_up_point? && order.return_all_unpacked_items?
        generate_margin(0, order)
      elsif order.organic? && order.pick_up_point?
        generate_margin(15, order)
      elsif order.induced?
        amount = PartnerMargin.calculate_margin(order)
        order.return_customer_orders.each do |return_order|
          line_item = return_order.shopoth_line_item
          price = (line_item.sub_total / line_item.quantity) || 0
          amount = (amount - (price * 0.05)).negative? ? 0 : (amount - (price * 0.05))
        end
        generate_margin(amount, order)
      else
        skip_partner_margin << order.id
      end
    end

    p "Skipped Warehouse Margin creation for customer order: #{skip_partner_margin}"
    p 'Partner Margin updating End'
  rescue StandardError => error
    Rails.logger.info error.full_message.to_s
    puts "--- Error occurred for due to: #{error}"
  end

  def generate_margin(amount, order)
    partner_margin = PartnerMargin.find_or_create_by(partner_id: order.partner_id, customer_order: order)
    partner_margin.update(order_type: order.order_type, margin_amount: amount)
  end

end
