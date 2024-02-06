class AddHomePageVisibilityToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :home_page_visibility, :boolean, default: 1
  end
end
