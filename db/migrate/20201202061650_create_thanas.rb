class CreateThanas < ActiveRecord::Migration[6.0]
  def change
    create_table :thanas do |t|
      t.integer :district_id, null: false
      t.string :name, null: false
      t.string :bn_name, null: false
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
