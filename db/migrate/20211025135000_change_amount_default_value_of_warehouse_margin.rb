class ChangeAmountDefaultValueOfWarehouseMargin < ActiveRecord::Migration[6.0]
  def change
    remove_column :warehouse_margins, :amount, :decimal
    add_column :warehouse_margins, :amount, :decimal, default: 0.0
  end
end
