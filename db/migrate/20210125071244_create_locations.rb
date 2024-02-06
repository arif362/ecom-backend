class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.string :code
      t.integer :warehouse_id
      t.timestamps
    end
  end
end
