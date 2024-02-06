class CreateProductAttributeImages < ActiveRecord::Migration[6.0]
  def change
    create_table :product_attribute_images do |t|
      t.integer :product_id
      t.integer :product_attribute_value_id
      t.boolean :is_default, default: false
      t.timestamps
    end
  end
end
