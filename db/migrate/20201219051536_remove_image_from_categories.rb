class RemoveImageFromCategories < ActiveRecord::Migration[6.0]
  def change
    remove_column :categories, :image, :string
  end
end
