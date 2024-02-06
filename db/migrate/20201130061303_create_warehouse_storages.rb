class CreateWarehouseStorages < ActiveRecord::Migration[6.0]
  def change
    create_table :warehouse_storages do |t|
      t.integer :warehouse_id, null: false
      t.string :name, null: false
      t.string :bn_name, null: false
      t.string :area, null: false
      t.string :location, null: false
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
