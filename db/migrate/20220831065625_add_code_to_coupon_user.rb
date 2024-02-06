class AddCodeToCouponUser < ActiveRecord::Migration[6.0]
  def change
    add_column :coupon_users, :code, :string
  end
end
