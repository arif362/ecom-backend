class AddColumnUseableIntoCouponsAndPromoCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :promo_coupons, :usable_count, :integer, default: 1
    add_column :promo_coupons, :usable_count_per_person, :integer, default: 1
    add_column :coupons, :used_count, :integer, default: 0
  end
end
