class CreateShopothLineItems < ActiveRecord::Migration[6.0]
  def change
    create_table :shopoth_line_items do |t|
      t.references :product, null: false, foreign_key: true
      t.integer "cart_id"
      t.integer "customer_order_id"
      t.integer "quantity", default: 1
      t.decimal "price", precision: 10, scale: 2, default: 0.0
      t.timestamps
    end
  end
end
