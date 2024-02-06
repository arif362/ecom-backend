class AddTimeStampToWarehouseBundle < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouse_bundles, :created_at, :datetime, precision: 6
    add_column :warehouse_bundles, :updated_at, :datetime, precision: 6
  end
end
