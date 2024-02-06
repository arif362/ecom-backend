class ChangeAgentMargin < ActiveRecord::Migration[6.0]
  def change
    remove_index :agent_margins, :customer_order_id
    remove_index :agent_margins, :warehouse_id
    rename_table :agent_margins, :warehouse_margins
    add_index :warehouse_margins, :customer_order_id
    add_index :warehouse_margins, :warehouse_id
  end
end
