class RemoveColumnsFromReturnOrders < ActiveRecord::Migration[6.0]
  def change
    remove_column :return_orders, :reason, :integer
    remove_column :return_orders, :description, :string
  end
end
