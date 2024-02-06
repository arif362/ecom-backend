class AddQuantityColumnsToStockChange < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_changes, :qc_pending_quantity, :integer, default: 0
    add_column :stock_changes, :qc_pending_quantity_change, :integer, default: 0
    add_column :stock_changes, :qty_qc_failed_quantity, :integer, default: 0
    add_column :stock_changes, :qty_qc_failed_quantity_change, :integer, default: 0
    add_column :stock_changes, :qly_qc_failed_quantity, :integer, default: 0
    add_column :stock_changes, :qly_qc_failed_quantity_change, :integer, default: 0
    add_column :stock_changes, :qty_return_qc_failed_quantity, :integer, default: 0
    add_column :stock_changes, :qty_return_qc_failed_quantity_change, :integer, default: 0
    add_column :stock_changes, :qly_return_qc_failed_quantity, :integer, default: 0
    add_column :stock_changes, :qly_return_qc_failed_quantity_change, :integer, default: 0
    add_column :stock_changes, :location_pending_quantity, :integer, default: 0
    add_column :stock_changes, :location_pending_quantity_change, :integer, default: 0
    add_column :stock_changes, :return_in_partner_quantity, :integer, default: 0
    add_column :stock_changes, :return_in_partner_quantity_change, :integer, default: 0
    add_column :stock_changes, :return_in_transit_quantity, :integer, default: 0
    add_column :stock_changes, :return_in_transit_quantity_change, :integer, default: 0
    add_column :stock_changes, :return_qc_pending_quantity, :integer, default: 0
    add_column :stock_changes, :return_qc_pending_quantity_change, :integer, default: 0
    add_column :stock_changes, :return_location_pending_quantity, :integer, default: 0
    add_column :stock_changes, :return_location_pending_quantity_change, :integer, default: 0
  end
end
