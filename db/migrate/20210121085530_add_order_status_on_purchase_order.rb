class AddOrderStatusOnPurchaseOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :dh_purchase_orders, :order_status, :integer, default: 0
    add_column :wh_purchase_orders, :order_status, :integer, default: 0
  end
end
