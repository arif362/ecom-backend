class CreatePromoCoupons < ActiveRecord::Migration[6.0]
  def change
    create_table :promo_coupons do |t|
      t.integer :status, null: false
      t.datetime :start_date
      t.integer :order_type
      t.datetime :end_date
      t.float :minimum_cart_value
      t.float :discount_amount
      t.float :max_discount_amount
      t.integer :discount_type
      t.boolean :is_deleted
      t.timestamps
    end
  end
end
