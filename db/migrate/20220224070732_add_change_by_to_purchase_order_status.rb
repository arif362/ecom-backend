class AddChangeByToPurchaseOrderStatus < ActiveRecord::Migration[6.0]
  def change
    add_column :purchase_order_statuses, :change_by_id, :bigint
    add_column :purchase_order_statuses, :change_by_type, :string
  end
end
