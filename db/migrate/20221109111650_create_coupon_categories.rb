class CreateCouponCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :coupon_categories do |t|
      t.bigint :coupon_id, null: false
      t.integer :category_inclusion_type, default: 0
      t.text :category_ids, array: true, default: []
      t.timestamps
    end
  end
end
