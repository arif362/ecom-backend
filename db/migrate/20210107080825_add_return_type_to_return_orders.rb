class AddReturnTypeToReturnOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :return_orders, :return_type, :integer, default: 0
  end
end
