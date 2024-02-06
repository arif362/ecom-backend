class WarehouseIdNullPromotions < ActiveRecord::Migration[6.0]
  def change
    change_column_null :promotions, :warehouse_id, true
  end
end
