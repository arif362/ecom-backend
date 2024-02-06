class AddBrandInfoVisibleToBrands < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :brand_info_visible, :boolean, default: true
  end
end
