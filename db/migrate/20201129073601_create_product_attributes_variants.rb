class CreateProductAttributesVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :product_attributes_variants do |t|
      t.integer :product_attribute_id
      t.integer :variant_id
      t.string :name
      t.string :value
      t.timestamps
    end
  end
end
