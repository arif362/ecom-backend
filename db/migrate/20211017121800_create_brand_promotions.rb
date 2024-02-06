class CreateBrandPromotions < ActiveRecord::Migration[6.0]
  def change
    create_table :brand_promotions do |t|
      t.integer :promotion_id
      t.integer :brand_id
      t.string :state

      t.timestamps
    end
  end
end
