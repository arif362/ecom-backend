class CreateStorageVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :storage_variants do |t|
      t.integer :warehouse_storage_id, null: false
      t.integer :variant_id, null: false
      t.integer :quantity, null: false
      t.timestamps
    end
  end
end
