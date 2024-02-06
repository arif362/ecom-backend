class RemoveMetaFromArticle < ActiveRecord::Migration[6.0]
  def change
    remove_column :articles, :meta_title
    remove_column :articles, :bn_meta_title
    remove_column :articles, :meta_keyword
    remove_column :articles, :bn_meta_keyword
    remove_column :articles, :meta_description
    remove_column :articles, :bn_meta_description
  end
end
