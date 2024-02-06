class AddDefaultToCouponUser < ActiveRecord::Migration[6.0]
  def change
    change_column_default :coupon_users, :number_of_uses, from: nil, to: 1
  end
end
