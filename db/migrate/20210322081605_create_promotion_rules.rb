class CreatePromotionRules < ActiveRecord::Migration[6.0]
  def change
    create_table :promotion_rules do |t|
      t.integer :promotion_id, null: false
      t.string :name
      t.decimal :value, precision: 10, scale: 2
      t.integer :coupon, default: 0

      t.timestamps
    end
  end
end
