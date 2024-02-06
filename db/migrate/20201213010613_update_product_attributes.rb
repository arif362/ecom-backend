class UpdateProductAttributes < ActiveRecord::Migration[6.0]
  def change
    # remove_column :products, :meta_keyword
    remove_column :products, :bn_meta_keyword
    remove_column :products, :warranty_type
    remove_column :products, :dangerous_goods
    remove_column :products, :sku_type
    add_column :products, :meta_keyword, :text, array: true, default: []
    add_column :products, :bn_meta_keyword, :text, array: true, default: []
    add_column :products, :warranty_type, :integer
    add_column :products, :dangerous_goods, :integer
    add_column :products, :sku_type, :integer
  end
end
