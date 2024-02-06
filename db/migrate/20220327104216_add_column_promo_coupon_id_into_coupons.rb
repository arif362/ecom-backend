class AddColumnPromoCouponIdIntoCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :promo_coupon_id, :bigint
  end
end
