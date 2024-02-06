class AddOrderStatusRefToCustomerOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :order_status_id, :integer
  end
end
