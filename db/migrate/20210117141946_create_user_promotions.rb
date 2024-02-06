class CreateUserPromotions < ActiveRecord::Migration[6.0]
  def change
    create_table :user_promotions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :customer_order, null:false , foreign_key: true
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0.0
      t.boolean :used, default: false
      t.timestamps
    end
  end
end
