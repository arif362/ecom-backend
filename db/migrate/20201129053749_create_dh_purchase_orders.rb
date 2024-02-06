class CreateDhPurchaseOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :dh_purchase_orders do |t|
      t.integer :supplier_id, null: false
      t.integer :warehouse_id, null: false
      t.integer :logistics_id, null: false
      t.integer :order_by, null: false
      t.decimal :quantity, precision: 8, scale: 2, null: false
      t.decimal :bn_quantity, precision: 8, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.decimal :bn_total_price, precision: 10, scale: 2, null: false
      t.string :status, null: false
      t.string :bn_status, null: false
      t.datetime :order_date
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
