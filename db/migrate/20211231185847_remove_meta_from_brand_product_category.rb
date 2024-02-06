class RemoveMetaFromBrandProductCategory < ActiveRecord::Migration[6.0]
  def change
    remove_column :brands, :meta_title
    remove_column :brands, :bn_meta_title
    remove_column :brands, :meta_keyword
    remove_column :brands, :bn_meta_keyword
    remove_column :brands, :meta_description
    remove_column :brands, :bn_meta_description

    remove_column :products, :meta_title
    remove_column :products, :bn_meta_title
    remove_column :products, :meta_keyword
    remove_column :products, :bn_meta_keyword
    remove_column :products, :meta_description
    remove_column :products, :bn_meta_description

    remove_column :categories, :meta_title
    remove_column :categories, :bn_meta_title
    remove_column :categories, :meta_keyword
    remove_column :categories, :bn_meta_keyword
    remove_column :categories, :meta_description
    remove_column :categories, :bn_meta_description
  end
end
