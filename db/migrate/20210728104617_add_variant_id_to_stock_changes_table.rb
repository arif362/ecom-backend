class AddVariantIdToStockChangesTable < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_changes, :variant_id, :integer
  end
end
