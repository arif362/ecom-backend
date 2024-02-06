class AddQuantityColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouse_variants, :ready_to_ship_from_fc_quantity, :integer, default: 0
    add_column :warehouse_variants, :in_transit_to_dh_quantity, :integer, default: 0
    add_column :warehouse_variants, :ready_to_ship_quantity, :integer, default: 0
    add_column :warehouse_variants, :return_in_dh_quantity, :integer, default: 0
    add_column :warehouse_variants, :return_in_transit_to_fc_quantity, :integer, default: 0
    add_column :stock_changes, :ready_to_ship_from_fc_quantity, :integer, default: 0
    add_column :stock_changes, :ready_to_ship_from_fc_quantity_change, :integer, default: 0
    add_column :stock_changes, :in_transit_to_dh_quantity, :integer, default: 0
    add_column :stock_changes, :in_transit_to_dh_quantity_change, :integer, default: 0
    add_column :stock_changes, :ready_to_ship_quantity, :integer, default: 0
    add_column :stock_changes, :ready_to_ship_quantity_change, :integer, default: 0
    add_column :stock_changes, :return_in_dh_quantity, :integer, default: 0
    add_column :stock_changes, :return_in_dh_quantity_change, :integer, default: 0
    add_column :stock_changes, :return_in_transit_to_fc_quantity, :integer, default: 0
    add_column :stock_changes, :return_in_transit_to_fc_quantity_change, :integer, default: 0
  end
end
