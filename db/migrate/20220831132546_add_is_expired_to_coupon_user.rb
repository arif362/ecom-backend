class AddIsExpiredToCouponUser < ActiveRecord::Migration[6.0]
  def change
    add_column :coupon_users, :is_expired, :boolean, default: false
  end
end
