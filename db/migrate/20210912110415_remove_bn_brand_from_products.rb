class RemoveBnBrandFromProducts < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :bn_brand, :string
  end
end
