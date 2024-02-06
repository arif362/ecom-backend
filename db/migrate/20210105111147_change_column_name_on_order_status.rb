class ChangeColumnNameOnOrderStatus < ActiveRecord::Migration[6.0]
  def change
    rename_column :order_statuses, :type, :order_type
  end
end
