class AddBundleQuantityToStockChanges < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_changes, :bundle_quantity, :integer, default: 0
    add_column :stock_changes, :bundle_quantity_change, :integer, default: 0
  end
end
