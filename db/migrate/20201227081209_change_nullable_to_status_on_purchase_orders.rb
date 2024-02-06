class ChangeNullableToStatusOnPurchaseOrders < ActiveRecord::Migration[6.0]
  def change
    change_column_null :wh_purchase_orders, :status, true
    change_column_null :dh_purchase_orders, :status, true
  end
end
