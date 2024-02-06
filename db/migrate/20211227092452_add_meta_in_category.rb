class AddMetaInCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :meta_title, :string
    add_column :categories, :bn_meta_title, :string
    add_column :categories, :meta_description, :text
    add_column :categories, :bn_meta_description, :text
    add_column :categories, :meta_keyword, :text, array: true, default: []
    add_column :categories, :bn_meta_keyword, :text, array: true, default: []
  end
end
