class AddColumnsToReturnCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :return_customer_orders, :reason, :integer, default: 0
    add_column :return_customer_orders, :description, :string
    add_column :return_customer_orders, :qr_code, :string
    add_reference :return_customer_orders, :shopoth_line_item, foreign_key: true
  end
end
