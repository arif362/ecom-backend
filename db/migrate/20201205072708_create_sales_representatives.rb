class CreateSalesRepresentatives < ActiveRecord::Migration[6.0]
  def change
    create_table :sales_representatives do |t|
      t.integer :warehouse_id, null: false
      t.string :name, null: false
      t.string :bn_name
      t.string :area, null: false
      t.string :bn_area
      t.timestamps
    end
  end
end
