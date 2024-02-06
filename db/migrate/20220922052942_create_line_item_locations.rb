class CreateLineItemLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :line_item_locations do |t|
      t.integer :location_id
      t.integer :shopoth_line_item_id
      t.integer :quantity
      t.integer :qr_code

      t.timestamps
    end
  end
end
