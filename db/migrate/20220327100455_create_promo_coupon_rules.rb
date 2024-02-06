class CreatePromoCouponRules < ActiveRecord::Migration[6.0]
  def change
    create_table :promo_coupon_rules do |t|
      t.bigint :promo_coupon_id, null: false
      t.references :ruleable, polymorphic: true
    end
  end
end
