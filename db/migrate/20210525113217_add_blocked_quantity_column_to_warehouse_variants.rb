class AddBlockedQuantityColumnToWarehouseVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouse_variants, :blocked_quantity, :integer, default: 0
  end
end
