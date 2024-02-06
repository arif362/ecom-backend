class AddDiscountTypeToCoupon < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :discount_type, :integer, default: 0
    add_column :coupons, :max_limit, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
