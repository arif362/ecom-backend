namespace :warehouse_margin do
  desc 'Script for warehouse margin create.'
  task create: :environment do |_t, _args|
    p 'Warehouse Margin generation Started'
    completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    partial_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
    returned_from_customer_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:returned_from_customer])
    returned_from_partner_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:returned_from_partner])
    orders = CustomerOrder.joins(:customer_order_status_changes).where(
      customer_order_status_changes: { order_status: completed_status },
    )
    orders.where('customer_orders.order_status_id = ?', completed_status.id).each do |order|
      p "Margin creating for customer order: #{order.id}"

      warehouse = order.warehouse
      amount = WarehouseMargin.generate_amount(warehouse, order)
      warehouse_margin = WarehouseMargin.find_or_create_by!(
        customer_order: order,
        warehouse: warehouse,
      )
      warehouse_margin.update_attributes!(amount: amount, is_commissionable: warehouse.is_commission_applicable)
    end

    orders.where('customer_orders.order_status_id = ? OR customer_orders.order_status_id = ? OR customer_orders.order_status_id = ?', partial_status.id, returned_from_customer_status.id, returned_from_partner_status.id).each do |order|
      p "Margin creating for customer order: #{order.id}"

      warehouse = order.warehouse
      if order.status == returned_from_customer_status || order.status == returned_from_partner_status
        warehouse_margin = WarehouseMargin.find_or_create_by!(
          customer_order: order,
          warehouse: warehouse,
        )
        warehouse_margin.update_attributes!(amount: 0, is_commissionable: warehouse.is_commission_applicable)
      else
        amount = WarehouseMargin.generate_amount(warehouse, order)
        order.return_customer_orders.each do |return_order|
          price = return_order.shopoth_line_item&.effective_unit_price || 0
          amount = (amount - (price * 0.015)).negative? ? 0 : (amount - (price * 0.015))
        end

        warehouse_margin = WarehouseMargin.find_or_create_by!(
          customer_order: order,
          warehouse: warehouse,
        )
        warehouse_margin.update_attributes!(amount: amount, is_commissionable: warehouse.is_commission_applicable)
      end

    end
    p 'Warehouse Margin generation End'
  end
end
