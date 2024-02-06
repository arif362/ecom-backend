class CreateCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_orders do |t|
      t.string "number"
      t.integer "item_count"
      t.text "special_instruction"
      t.integer "pay_type"
      t.decimal "cart_total_price", precision: 10, scale: 2, default: 0.0
      t.integer "order_status"
      t.integer "for_whom"
      t.datetime "completed_at"
      t.string "coupon_code"
      t.timestamps
    end
  end
end
