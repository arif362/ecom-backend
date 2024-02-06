class RemoveBrandFromProduct < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :brand, :string
  end
end
