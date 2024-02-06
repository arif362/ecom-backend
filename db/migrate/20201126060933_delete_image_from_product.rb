class DeleteImageFromProduct < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :image, :string
  end
end
