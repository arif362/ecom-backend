class AddColumnsToProductsAndCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :is_emi_available, :boolean, default: false
    add_column :products, :tenures, :integer, array: true, default: []
    add_column :customer_orders, :is_emi_applied, :boolean, default: false
    add_column :customer_orders, :tenure, :integer
  end
end
