namespace :cancel_orders do
  task online_payments_pending: :environment do |t, args|
    day = 1.day.ago.end_of_day
    status_id = OrderStatus.getOrderStatus(OrderStatus.order_types[:order_placed])
    customer_orders = CustomerOrder.where.not(pay_type: 'cash_on_delivery').
                      where('is_customer_paid = ? AND
                      created_at <= ? AND order_status_id = ?', false, day, status_id)
    customer_orders.each do |co|
      cancel_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:cancelled])
      co.update_columns(order_status_id: cancel_status.id)
      co.shopoth_line_items.each do |line_item|
        warehouse_variant = WarehouseVariant.find_by!(warehouse: co.warehouse, variant: line_item.variant)
        warehouse_variant.update!(
          available_quantity: warehouse_variant.available_quantity + line_item.quantity,
          booked_quantity: warehouse_variant.booked_quantity - line_item.quantity,
          )
        warehouse_variant.save_stock_change('cancel_from_order_placed', line_item.quantity, line_item.customer_order,
                                            'booked_quantity_change', 'available_quantity_change')
      end
      Rails.logger.info "###### Successfully cancelled: #{co.id} ###############"
    rescue => error
      Rails.logger.info "######failed to update order status for co: #{co.id} due to #{error.message} ######"
      next
    end
  end
end
