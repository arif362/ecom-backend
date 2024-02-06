class AddColsToBannerImage < ActiveRecord::Migration[6.0]
  def change
    add_column :banner_images, :image_title, :string, default: ''
    add_column :banner_images, :description, :string, default: ''
  end
end
