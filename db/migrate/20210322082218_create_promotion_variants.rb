class CreatePromotionVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :promotion_variants do |t|
      t.integer :promotion_id, null: false
      t.integer :variant_id, null: false
      t.string :state
      t.decimal :quantity, precision: 10, scale: 2
      t.integer :coupon, default: 0

      t.timestamps
    end
  end
end
