class ChangeReturnTransferOrders < ActiveRecord::Migration[6.0]
  def change
    change_column :return_transfer_orders, :quantity, :integer, default: 0
  end
end
