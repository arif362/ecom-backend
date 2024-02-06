class AddPromotionIdCouponCodeCarts < ActiveRecord::Migration[6.0]
  def change
    add_column :carts, :promotion_id, :integer
    add_column :carts, :coupon_code, :string
  end
end
