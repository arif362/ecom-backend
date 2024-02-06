class AddColsToReturnCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :return_customer_orders, :sub_total, :decimal, scale: 2, precision: 10, default: 0.0
    add_column :return_customer_orders, :grand_total, :decimal, scale: 2, precision: 10, default: 0.0
    add_column :return_customer_orders, :refunded, :boolean, default: false
  end
end
