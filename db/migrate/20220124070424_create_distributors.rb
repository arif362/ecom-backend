class CreateDistributors < ActiveRecord::Migration[6.0]
  def change
    create_table :distributors do |t|
      t.string :name
      t.string :bn_name
      t.integer :warehouse_id, null: false
      t.timestamps
    end
  end
end
