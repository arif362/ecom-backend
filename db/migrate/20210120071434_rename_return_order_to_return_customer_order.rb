class RenameReturnOrderToReturnCustomerOrder < ActiveRecord::Migration[6.0]
  def change
    rename_table :return_orders, :return_customer_orders
  end
end
