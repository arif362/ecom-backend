class AddColumnsToCoupon < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :coupon_type, :integer, default: 0
    add_column :coupons, :is_active, :boolean, default: true
  end
end
