class AddBnCustomerOrderStatusInStatusTable < ActiveRecord::Migration[6.0]
  def change
    add_column :order_statuses, :bn_customer_order_status, :string, default: ''
  end
end
