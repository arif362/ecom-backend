class PositionFooterArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :footer_visibility, :boolean, default: false
    add_column :articles, :position, :integer, default: 0
  end
end
