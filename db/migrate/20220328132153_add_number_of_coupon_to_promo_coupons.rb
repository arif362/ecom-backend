class AddNumberOfCouponToPromoCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :promo_coupons, :number_of_coupon, :integer
  end
end
