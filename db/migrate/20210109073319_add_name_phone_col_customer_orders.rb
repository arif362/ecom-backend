class AddNamePhoneColCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :name, :string
    add_column :customer_orders, :phone, :string
  end
end
