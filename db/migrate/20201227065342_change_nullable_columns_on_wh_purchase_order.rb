class ChangeNullableColumnsOnWhPurchaseOrder < ActiveRecord::Migration[6.0]
  def change
    if column_exists? :wh_purchase_orders, :logistic_id
      change_column_null :wh_purchase_orders, :logistic_id, true
    end
    change_column_null :wh_purchase_orders, :order_by, true
    change_column_null :wh_purchase_orders, :bn_quantity, true
    change_column_null :wh_purchase_orders, :bn_status, true
    change_column_null :wh_purchase_orders, :bn_total_price, true
  end
end
