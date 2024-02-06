class AddProductAttributeValueIdToProductAttributesVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :product_attributes_variants, :product_attribute_value_id, :integer
    remove_column  :product_attributes_variants, :product_attribute_id, :integer
    remove_column  :product_attributes_variants, :name, :string
    remove_column  :product_attributes_variants, :value, :string
  end
end
