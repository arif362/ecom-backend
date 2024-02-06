class RemoveHeroImageImagesFromProducts < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :hero_image, :string
    remove_column :products, :images, :string
  end
end
