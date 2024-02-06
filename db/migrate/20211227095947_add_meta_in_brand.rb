class AddMetaInBrand < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :meta_title, :string
    add_column :brands, :bn_meta_title, :string
    add_column :brands, :meta_description, :text
    add_column :brands, :bn_meta_description, :text
    add_column :brands, :meta_keyword, :text, array: true, default: []
    add_column :brands, :bn_meta_keyword, :text, array: true, default: []
  end
end
