class CreateWishlists < ActiveRecord::Migration[6.0]
  def change
    create_table :wishlists do |t|
      t.integer :product_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end
