class AddMultiUserToCoupon < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :max_user_limit, :integer
    add_column :coupons, :is_multiple_used, :integer, default: 1
  end
end
