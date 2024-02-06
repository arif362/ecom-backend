class RemoveSupplierIdFromDhPurchaseOrders < ActiveRecord::Migration[6.0]
  def change
    remove_column :dh_purchase_orders, :supplier_id, :integer
  end
end
