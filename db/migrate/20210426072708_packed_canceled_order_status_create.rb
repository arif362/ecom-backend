class PackedCanceledOrderStatusCreate < ActiveRecord::Migration[6.0]
  def up
    type_key = 'packed_cancelled'
    status = "order_#{type_key}"
    OrderStatus.create(
      order_type: type_key,
      system_order_status: status,
      customer_order_status: 'Packed Cancelled',
      admin_order_status: 'Packed Cancelled',
      sales_representative_order_status: status,
      partner_order_status: status
    )
  end

  def down
    type_key = OrderStatus::order_types[:packed_cancelled]
    OrderStatus.find_by(order_type: type_key).destroy
  end
end
