class AddColumnsToLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :line_items, :received_quantity, :integer, default: 0
    add_column :line_items, :qc_passed, :integer, default: 0
    add_column :line_items, :qc_failed, :integer, default: 0
    add_column :line_items, :qc_status, :boolean, default: false
  end
end
