class CreateProductFeatures < ActiveRecord::Migration[6.0]
  def change
    create_table :product_features do |t|
      t.integer :product_id
      t.string :title, default: ''
      t.string :bn_title, default: ''
      t.string :description, default: ''
      t.string :bn_description, default: ''

      t.timestamps
    end
  end
end
