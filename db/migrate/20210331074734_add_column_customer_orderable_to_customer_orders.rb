class AddColumnCustomerOrderableToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :customer_orderable_id, :integer
    add_column :customer_orders, :customer_orderable_type, :string
  end
end
