class CreateProductCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :product_categories do |t|
      t.references :product, null: false, foreign_key: true, index: true
      t.references :category, null: false, foreign_key: true, index: true
      t.integer :sub_category_id, null: true, foreign_key: true, index: true

      t.timestamps
    end
  end
end
