class AddMetaInProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :meta_title, :string
    add_column :products, :bn_meta_title, :string
    add_column :products, :meta_description, :text
    add_column :products, :bn_meta_description, :text
  end
end
