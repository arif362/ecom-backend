class CreateAreas < ActiveRecord::Migration[6.0]
  def change
    create_table :areas do |t|
      t.integer :thana_id, null: false
      t.string :name, null: false
      t.string :bn_name, null: false
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
