class AddIsVisibleToCoupon < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :is_visible, :boolean, default: true
  end
end
