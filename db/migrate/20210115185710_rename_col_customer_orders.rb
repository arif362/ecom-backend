class RenameColCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    rename_column :customer_orders, :adjustment_total, :total_discount_amount
  end
end
