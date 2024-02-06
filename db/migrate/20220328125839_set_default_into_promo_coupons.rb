class SetDefaultIntoPromoCoupons < ActiveRecord::Migration[6.0]
  def change
    change_column :promo_coupons, :is_deleted, :boolean, default: false
    change_column :promo_coupons, :status, :integer, default: 1
    change_column :promo_coupons, :order_type, :integer, default: 0
    change_column :promo_coupons, :discount_type, :integer, default: 0
  end
end
