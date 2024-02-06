class CreateWarehouseVariantsLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :warehouse_variants_locations do |t|
      t.integer :warehouse_variant_id
      t.integer :location_id
      t.integer :quantity
      t.timestamps
    end
  end
end
