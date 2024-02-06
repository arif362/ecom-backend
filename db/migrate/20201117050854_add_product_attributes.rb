class AddProductAttributes < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :type, :string, index: true
    add_column :products, :bn_title, :string, index: true, null: false
    add_column :products, :bn_description, :string
    add_column :products, :bn_meta_keyword, :string
    change_column :products, :quantity, :decimal, precision: 10, scale: 2
    add_index :products, :title
    change_column :products, :title, :string, null: false
  end
end
