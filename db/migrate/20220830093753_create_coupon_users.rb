class CreateCouponUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :coupon_users do |t|
      t.float :discount_amount, default: 0.0
      t.boolean :is_used, default: false
      t.integer :user_id, null: false
      t.integer :coupon_id, null: false
      t.integer :customer_order_id

      t.timestamps
    end
  end
end
