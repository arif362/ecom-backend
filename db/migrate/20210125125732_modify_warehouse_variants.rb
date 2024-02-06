class ModifyWarehouseVariants < ActiveRecord::Migration[6.0]
  def change
    change_column_default :warehouse_variants, :available_quantity, 0
    change_column_default :warehouse_variants, :booked_quantity, 0
    change_column_default :warehouse_variants, :packed_quantity, 0
  end
end
