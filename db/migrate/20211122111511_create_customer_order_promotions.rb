class CreateCustomerOrderPromotions < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_order_promotions do |t|
      t.references :customer_order, foreign_key: true, null: false
      t.references :promotion, foreign_key: true, null: false
      t.timestamps
    end
  end
end
