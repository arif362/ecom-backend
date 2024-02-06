class CreateCoupons < ActiveRecord::Migration[6.0]
  def change
    create_table :coupons do |table|
      table.integer :warehouse_id, null: false
      table.string :code, null: false
      table.integer :discount_type, null: false, default: 0
      table.decimal :discount_amount, null: false, precision: 10, scale: 2
      table.decimal :max_discount, precision: 10, scale: 2
      table.datetime :start_at
      table.datetime :end_at
      table.integer :status, default: 0
      table.timestamps
    end
  end
end
