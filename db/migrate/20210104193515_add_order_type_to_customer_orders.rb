class AddOrderTypeToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :order_type, :integer, default: 0, null: false
  end
end
