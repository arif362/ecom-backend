class DropCustomerCoupons < ActiveRecord::Migration[6.0]
  def change
    drop_table :customer_coupons
  end
end
