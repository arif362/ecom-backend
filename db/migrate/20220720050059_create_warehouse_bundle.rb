class CreateWarehouseBundle < ActiveRecord::Migration[6.0]
  def change
    create_table :warehouse_bundles do |t|
      t.integer :warehouse_id, null: false
      t.integer :bundle_id, null: false
    end
  end
end
