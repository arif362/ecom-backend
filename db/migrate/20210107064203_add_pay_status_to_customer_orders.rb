class AddPayStatusToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :pay_status, :integer, default: 0
  end
end
