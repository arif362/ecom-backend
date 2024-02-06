class AddIsOwnBrandToBrands < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :is_own_brand, :boolean, default: false
  end
end
