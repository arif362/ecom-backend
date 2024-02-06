# rubocop:disable Style/Documentation
class CreateWarehouses < ActiveRecord::Migration[6.0]
  def change
    create_table :warehouses do |t|
      t.string :name, null: false
      t.string :bn_name
      t.string :warehouse_type, null: false
      t.integer :capacity, default: 0

      t.timestamps
    end
  end
end
