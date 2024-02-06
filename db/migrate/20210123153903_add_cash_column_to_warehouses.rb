class AddCashColumnToWarehouses < ActiveRecord::Migration[6.0]
  def change
    remove_column :warehouses, :collected_cash_from_routes
    add_column :warehouses, :collected_cash_from_routes, :decimal, default: 0
  end
end
