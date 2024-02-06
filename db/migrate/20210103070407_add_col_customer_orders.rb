class AddColCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :shipping_fee, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
