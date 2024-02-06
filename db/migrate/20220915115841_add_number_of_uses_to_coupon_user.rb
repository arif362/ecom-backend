class AddNumberOfUsesToCouponUser < ActiveRecord::Migration[6.0]
  def change
    add_column :coupon_users, :number_of_uses, :integer
  end
end
