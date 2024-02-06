class RenameColumnsInStockChange < ActiveRecord::Migration[6.0]
  def change
    rename_column :stock_changes, :qty_return_qc_failed_quantity, :return_qty_qc_failed_quantity
    rename_column :stock_changes, :qty_return_qc_failed_quantity_change, :return_qty_qc_failed_quantity_change
    rename_column :stock_changes, :qly_return_qc_failed_quantity, :return_qly_qc_failed_quantity
    rename_column :stock_changes, :qly_return_qc_failed_quantity_change, :return_qly_qc_failed_quantity_change
  end
end
