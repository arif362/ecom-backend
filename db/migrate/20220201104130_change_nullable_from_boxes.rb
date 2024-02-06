class ChangeNullableFromBoxes < ActiveRecord::Migration[6.0]
  def change
    change_column_null :boxes, :dh_purchase_order_id, true
  end
end
