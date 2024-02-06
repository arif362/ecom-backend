class AddQuantityOnRco < ActiveRecord::Migration[6.0]
  def change
    add_column :return_customer_orders, :quantity, :integer
  end
end
