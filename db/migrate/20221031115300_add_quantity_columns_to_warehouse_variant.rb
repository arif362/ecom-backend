class AddQuantityColumnsToWarehouseVariant < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouse_variants, :qc_pending_quantity, :integer, default: 0
    add_column :warehouse_variants, :qty_qc_failed_quantity, :integer, default: 0
    add_column :warehouse_variants, :qly_qc_failed_quantity, :integer, default: 0
    add_column :warehouse_variants, :location_pending_quantity, :integer, default: 0
    add_column :warehouse_variants, :return_in_partner_quantity, :integer, default: 0
    add_column :warehouse_variants, :return_in_transit_quantity, :integer, default: 0
    add_column :warehouse_variants, :return_qc_pending_quantity, :integer, default: 0
    add_column :warehouse_variants, :return_qty_qc_failed_quantity, :integer, default: 0
    add_column :warehouse_variants, :return_qly_qc_failed_quantity, :integer, default: 0
    add_column :warehouse_variants, :return_location_pending_quantity, :integer, default: 0
  end
end
