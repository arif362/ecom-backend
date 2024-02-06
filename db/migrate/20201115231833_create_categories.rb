class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :title, null: false
      t.text :description
      t.integer :parent_id
      t.text :image
      t.string :bn_title, null: false
      t.text :bn_description
      t.timestamps
    end
  end
end
