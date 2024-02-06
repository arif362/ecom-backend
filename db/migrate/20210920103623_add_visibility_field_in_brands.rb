class AddVisibilityFieldInBrands < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :visibility, :boolean, default: true
  end
end
