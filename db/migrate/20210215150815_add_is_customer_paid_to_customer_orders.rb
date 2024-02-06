class AddIsCustomerPaidToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :is_customer_paid, :boolean, default: false
  end
end
