class ReplaceReturnQlyQcFailedQuantity < ActiveRecord::Migration[6.0]
  def change
    remove_column :warehouse_variants, :return_qly_qc_failed_quantity
    remove_column :warehouse_variants, :return_qty_qc_failed_quantity
    remove_column :stock_changes, :return_qly_qc_failed_quantity
    remove_column :stock_changes, :return_qly_qc_failed_quantity_change
    remove_column :stock_changes, :return_qty_qc_failed_quantity
    remove_column :stock_changes, :return_qty_qc_failed_quantity_change

    add_column :warehouse_variants, :return_qc_failed_quantity, :integer, default: 0
    add_column :stock_changes, :return_qc_failed_quantity, :integer, default: 0
    add_column :stock_changes, :return_qc_failed_quantity_change, :integer, default: 0
  end
end
