class CreateOcLineItems < ActiveRecord::Migration[6.0]
  def change
    create_table :oc_line_items do |t|
      t.references :oc_product, null: false, foreign_key: true, index: true
      t.references :oc_purchase_order, null: false, foreign_key: true, index: true
      t.integer :quantity
      t.decimal :unit_price, precision: 10, scale: 2, default: 0.0
      t.decimal :total_price, precision: 10, scale: 2, default: 0.0
      t.datetime :acquisition_date
      t.timestamps
    end
  end
end
