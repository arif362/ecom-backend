class CreateRaCoupons < ActiveRecord::Migration[6.0]
  def change
    create_table :ra_coupons do |t|
      t.integer :promotion_id
      t.integer :retailer_assistant_id
      t.string :code
      t.boolean :is_used
      t.boolean :is_deleted
      t.timestamps
    end
  end
end
