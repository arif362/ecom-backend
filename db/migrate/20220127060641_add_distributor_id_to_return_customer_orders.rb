class AddDistributorIdToReturnCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :return_customer_orders, :distributor_id, :bigint
  end
end
