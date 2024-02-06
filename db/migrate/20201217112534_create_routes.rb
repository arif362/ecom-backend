class CreateRoutes < ActiveRecord::Migration[6.0]
  def change
    create_table :routes do |t|
      t.string :title, null: false
      t.string :bn_title, null: false
      t.string :phone
      t.integer :warehouse_id
      t.timestamps
    end
  end
end
