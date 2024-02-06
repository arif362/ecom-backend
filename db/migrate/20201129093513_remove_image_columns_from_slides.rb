class RemoveImageColumnsFromSlides < ActiveRecord::Migration[6.0]
  def change
    remove_column :slides, :image_file_name, :string
    remove_column :slides, :image_content_type, :string
    remove_column :slides, :image_file_size, :integer
    remove_column :slides, :image_updated_at, :datetime
  end
end
