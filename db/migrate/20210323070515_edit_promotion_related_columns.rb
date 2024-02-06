class EditPromotionRelatedColumns < ActiveRecord::Migration[6.0]
  def up
    remove_column :promotion_rules, :coupon
    remove_column :promotion_variants, :coupon
    remove_column :promotion_variants, :quantity

    add_column :promotions, :coupons, :integer, { default: 0 }
    add_column :promotions, :buy_x_qty, :integer, { default: 0 }
    add_column :promotions, :get_y_qty, :integer, { default: 0 }
  end

  def down
    add_column :promotion_rules, :coupon, :integer, { default: 0 }
    add_column :promotion_variants, :coupon, :integer, { default: 0 }
    add_column :promotion_variants, :quantity, :integer, { default: 0 }

    remove_column :promotions, :coupons
    remove_column :promotions, :buy_x_qty
    remove_column :promotions, :get_y_qty
  end
end
