class CreateSearches < ActiveRecord::Migration[6.0]
  def change
    create_table :searches do |t|
      t.integer :warehouse_id
      t.integer :user_id
      t.string :search_key, null: false
      t.string :product_ids, array: true, default: []

      t.timestamps
    end
  end
end
