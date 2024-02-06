class AddColumnsInProductAttributes < ActiveRecord::Migration[6.0]
  def change
    add_column :product_attributes, :bn_name, :string
    add_column :product_attribute_values, :bn_value, :string
    add_column :product_attribute_values, :is_deleted, :boolean, default: false
  end
end
