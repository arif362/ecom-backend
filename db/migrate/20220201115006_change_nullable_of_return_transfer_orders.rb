class ChangeNullableOfReturnTransferOrders < ActiveRecord::Migration[6.0]
  def change
    change_column_null :return_transfer_orders, :quantity, true
    change_column_null :return_transfer_orders, :total_price, true
    remove_column :return_transfer_orders, :order_date, :datetime
  end
end
