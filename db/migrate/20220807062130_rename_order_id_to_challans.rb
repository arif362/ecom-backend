class RenameOrderIdToChallans < ActiveRecord::Migration[6.0]
  def change
    rename_column :challan_line_items, :order_id, :customer_order_id
  end
end
