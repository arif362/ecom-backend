class AddColToWarehouseVariantsLocations < ActiveRecord::Migration[6.0]
  def change
    remove_column :warehouse_variants_locations, :quantity, :integer
    add_column :warehouse_variants_locations, :quantity, :integer, default: 0
  end
end
