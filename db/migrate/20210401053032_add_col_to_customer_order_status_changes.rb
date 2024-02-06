class AddColToCustomerOrderStatusChanges < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_order_status_changes, :changed_by_id, :integer
    add_column :customer_order_status_changes, :changed_by_type, :string
  end
end
