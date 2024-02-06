class RemoveFieldFromStaticPages < ActiveRecord::Migration[6.0]
  def change
    remove_column :static_pages, :body, :text
    remove_column :static_pages, :slug, :string
    remove_column :static_pages, :is_active, :integer
    remove_column :static_pages, :show_in_footer, :boolean
    remove_column :static_pages, :position, :integer
    remove_column :static_pages, :created_at, :datetime
    remove_column :static_pages, :updated_at, :datetime
  end
end
