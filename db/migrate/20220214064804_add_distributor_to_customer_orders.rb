class AddDistributorToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :distributor_id, :bigint
  end
end
