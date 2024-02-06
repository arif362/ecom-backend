class AddCartValueToCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :cart_value, :decimal
  end
end
