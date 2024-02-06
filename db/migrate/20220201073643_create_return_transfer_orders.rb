class CreateReturnTransferOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :return_transfer_orders do |t|
      t.integer :warehouse_id, null: false
      t.integer :order_by
      t.decimal :quantity, precision: 8, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.integer :order_status, default: 0
      t.datetime :order_date
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
