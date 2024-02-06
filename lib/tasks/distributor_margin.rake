namespace :distributor_margin do
  desc 'Script for dh margin create.'
  task update: :environment do |_t, _args|
    p 'distributor Margin generation Started'
    completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    partial_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
    returned_from_customer_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:returned_from_customer])
    returned_from_partner_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:returned_from_partner])
    # margin issue fixing for without return and promotion coupon applied orders
    orders = CustomerOrder.where(coupon_code: Coupon.multi_user.map(&:code) + Coupon.first_registration.map(&:code)).joins(:customer_order_status_changes).where(
      customer_order_status_changes: { order_status: completed_status },
      )
    orders.where('customer_orders.order_status_id = ?', completed_status.id).each do |order|
      p "Margin updating for customer order: #{order.id}"

      order.update_columns(return_coupon: false)

      distributor = order.distributor
      amount = DistributorMargin.generate_amount(distributor, order)
      distributor_margin = DistributorMargin.find_or_create_by!(
        customer_order: order,
        distributor: distributor,
        )
      distributor_margin.update_attributes!(amount: amount, is_commissionable: distributor.is_commission_applicable)
    end

    orders.where('customer_orders.order_status_id = ? OR customer_orders.order_status_id = ? OR customer_orders.order_status_id = ?', partial_status.id, returned_from_customer_status.id, returned_from_partner_status.id).each do |order|
      p "Margin creating for customer order: #{order.id}"

      distributor = order.distributor
      if order.status == returned_from_customer_status || order.status == returned_from_partner_status
        distributor_margin = DistributorMargin.find_or_create_by!(
          customer_order: order,
          distributor: distributor,
          )
        distributor_margin.update_attributes!(amount: 0, is_commissionable: distributor.is_commission_applicable)
      else
        amount = DistributorMargin.generate_amount(distributor, order)
        order.return_customer_orders.each do |return_order|
          price = return_order.shopoth_line_item&.effective_unit_price || 0
          amount = (amount - (price * 0.015)).negative? ? 0 : (amount - (price * 0.015))
        end

        distributor_margin = DistributorMargin.find_or_create_by!(
          customer_order: order,
          distributor: distributor,
          )
        distributor_margin.update_attributes!(amount: amount, is_commissionable: distributor.is_commission_applicable)
      end

    end
    p 'distributor Margin generation End'
  end
end
