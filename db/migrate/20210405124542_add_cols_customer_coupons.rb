class AddColsCustomerCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_coupons, :usable_type, :string
    add_column :customer_coupons, :usable_id, :integer
    remove_column :customer_coupons, :discount_amount, :decimal
    remove_column :customer_coupons, :cart_value, :decimal
    remove_column :customer_coupons, :user_id, :integer
  end
end
