class AddPublicVisibilityInProductTable < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :public_visibility, :boolean, default: true
  end
end
