class AddHomePageVisibilityInBrands < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :homepage_visibility, :boolean, default: false
    rename_column :brands, :visibility, :public_visibility
  end
end
