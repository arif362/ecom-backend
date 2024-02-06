class RemoveUsedCountInCouponUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :coupon_users, :number_of_uses, :integer
  end
end
