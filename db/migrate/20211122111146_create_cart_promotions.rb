class CreateCartPromotions < ActiveRecord::Migration[6.0]
  def change
    create_table :cart_promotions do |t|
      t.references :cart, foreign_key: true, null: false
      t.references :promotion, foreign_key: true, null: false
      t.timestamps
    end
  end
end
