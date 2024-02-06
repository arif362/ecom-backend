class CreatePromotions < ActiveRecord::Migration[6.0]
  def change
    create_table :promotions do |t|
      t.integer :warehouse_id, null: false
      t.integer :promotion_category, default: 0
      t.date :from_date
      t.date :to_date
      t.boolean :is_active, default: true
      t.boolean :is_time_bound, default: false
      t.string :start_time
      t.string :end_time
      t.string :days, array: true

      t.timestamps

      t.index :warehouse_id
      t.index :promotion_category
    end
  end
end
