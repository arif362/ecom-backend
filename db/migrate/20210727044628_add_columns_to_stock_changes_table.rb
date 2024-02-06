class AddColumnsToStockChangesTable < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_changes, :available_quantity_change, :integer, default: 0
    add_column :stock_changes, :booked_quantity_change, :integer, default: 0
    add_column :stock_changes, :packed_quantity_change, :integer, default: 0
    add_column :stock_changes, :in_transit_quantity_change, :integer, default: 0
    add_column :stock_changes, :in_partner_quantity_change, :integer, default: 0
    add_column :stock_changes, :blocked_quantity_change, :integer, default: 0
    add_column :stock_changes, :garbage_quantity_change, :integer, default: 0
    add_column :stock_changes, :warehouse_id, :integer
    add_column :stock_changes, :stock_transaction_type, :integer
    remove_column :stock_changes, :stock_transaction_reason, :string
  end
end
