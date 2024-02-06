class AddIsDeletedToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :is_deletable, :boolean, default: true
  end
end
