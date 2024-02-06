class CreateCustomerCoupons < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_coupons do |t|
      t.string :coupon_code
      t.boolean :is_used, default: false
      t.integer :user_id
      t.integer :customer_order_id
      t.integer :promotion_id
      t.decimal :cart_value, precision: 10, scale: 2, default: 0.0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0.0
      t.timestamps
    end
  end
end
