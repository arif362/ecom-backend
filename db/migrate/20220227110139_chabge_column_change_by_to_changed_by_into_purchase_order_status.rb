class ChabgeColumnChangeByToChangedByIntoPurchaseOrderStatus < ActiveRecord::Migration[6.0]
  def change
    rename_column :purchase_order_statuses, :change_by_type, :changed_by_type
    rename_column :purchase_order_statuses, :change_by_id, :changed_by_id
  end
end
