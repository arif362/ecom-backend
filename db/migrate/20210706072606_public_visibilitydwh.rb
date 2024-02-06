class PublicVisibilitydwh < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouses, :public_visibility, :boolean, default: true
  end
end
