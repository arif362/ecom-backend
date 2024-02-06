class CreateCustomerOrderStatusChange < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_order_status_changes do |t|
      t.references :customer_order, null: false, foreign_key: true
      t.references :order_status, null: false, foreign_key: true
      t.timestamps
    end
  end
end
