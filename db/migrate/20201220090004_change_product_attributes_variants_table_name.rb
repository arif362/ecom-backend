class ChangeProductAttributesVariantsTableName < ActiveRecord::Migration[6.0]
  def change
    rename_table :product_attributes_variants, :product_attribute_values_variants
  end
end
