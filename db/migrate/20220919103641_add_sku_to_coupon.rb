class AddSkuToCoupon < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :skus, :text
  end
end
