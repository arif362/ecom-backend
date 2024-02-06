class CreateLineItems < ActiveRecord::Migration[6.0]
  def change
    create_table :line_items do |t|
      t.integer :variant_id, null: false
      t.integer :quantity, null: false
      t.decimal :price, precision: 10, scale: 2, default: 0.0
      t.references :itemable, polymorphic: true
      t.timestamps
    end
  end
end
