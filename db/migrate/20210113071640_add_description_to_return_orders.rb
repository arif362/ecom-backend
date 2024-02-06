class AddDescriptionToReturnOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :return_orders, :description, :string, default: ''
  end
end
