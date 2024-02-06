class AddCollectedCashFromRoutesToWarehouses < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouses, :collected_cash_from_routes, :decimal, precision: 15, scale: 13, default: 0
  end
end
