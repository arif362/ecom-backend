class AddPageTypeInStaticPage < ActiveRecord::Migration[6.0]
  def change
    add_column :static_pages, :page_type, :integer
    remove_column :static_pages, :title, :string
  end
end
