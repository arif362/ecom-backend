class CreateOcProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :oc_products do |t|
      t.string :title
      t.string :model_name
      t.integer :root_category_id, null: false
      t.integer :leaf_category_id, null: false
      t.timestamps
    end
  end
end
