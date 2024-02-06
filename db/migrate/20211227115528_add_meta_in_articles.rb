class AddMetaInArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :meta_title, :string
    add_column :articles, :bn_meta_title, :string
    add_column :articles, :meta_description, :text
    add_column :articles, :bn_meta_description, :text
    add_column :articles, :meta_keyword, :text, array: true, default: []
    add_column :articles, :bn_meta_keyword, :text, array: true, default: []
  end
end
