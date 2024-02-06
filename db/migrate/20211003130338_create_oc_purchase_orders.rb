class CreateOcPurchaseOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :oc_purchase_orders do |t|
      t.references :oc_supplier, null: false, foreign_key: true, index: true
      t.integer :quantity
      t.decimal :total_price, scale: 2, precision: 10, default: 0.0
      t.timestamps
    end
  end
end
