class RenameColumnDiscountAmountToDiscountIntoPromoCoupons < ActiveRecord::Migration[6.0]
  def change
    rename_column :promo_coupons, :discount_amount, :discount
  end
end
