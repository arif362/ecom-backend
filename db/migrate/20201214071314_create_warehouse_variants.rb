class CreateWarehouseVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :warehouse_variants do |t|
      t.integer :warehouse_id, null: false
      t.integer :variant_id, null: false
      t.integer :booked_quantity, null: false
      t.integer :available_quantity, null: false
      t.integer :packed_quantity, null: false
      t.timestamps
    end
  end
end
