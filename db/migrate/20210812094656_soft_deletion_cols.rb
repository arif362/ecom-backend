class SoftDeletionCols < ActiveRecord::Migration[6.0]
  def change
    add_column :product_attributes, :is_deleted, :boolean, default: false
    add_column :product_attribute_values_variants, :is_deleted, :boolean, default: false
    add_column :product_attribute_images, :is_deleted, :boolean, default: false
  end
end
