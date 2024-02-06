class AddColumnToWarehouseVariant < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouse_variants, :failed_qc_unsettled_quantity, :integer, default: 0
    add_column :stock_changes, :failed_qc_unsettled_quantity, :integer, default: 0
    add_column :stock_changes, :failed_qc_unsettled_quantity_change, :integer, default: 0
  end
end
