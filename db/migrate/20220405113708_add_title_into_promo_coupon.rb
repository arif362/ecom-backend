class AddTitleIntoPromoCoupon < ActiveRecord::Migration[6.0]
  def change
    add_column :promo_coupons, :title, :string
  end
end
