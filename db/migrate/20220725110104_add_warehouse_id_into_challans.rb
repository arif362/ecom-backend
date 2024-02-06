class AddWarehouseIdIntoChallans < ActiveRecord::Migration[6.0]
  def change
    add_column :challans, :warehouse_id, :bigint
  end
end
