class RemoveBundleQuantityFromStockChanges < ActiveRecord::Migration[6.0]
  def change
    remove_column :stock_changes, :bundle_quantity
    remove_column :stock_changes, :bundle_quantity_change
  end
end
