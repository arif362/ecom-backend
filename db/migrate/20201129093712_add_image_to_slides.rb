class AddImageToSlides < ActiveRecord::Migration[6.0]
  def change
    add_column :slides, :image, :string
  end
end
