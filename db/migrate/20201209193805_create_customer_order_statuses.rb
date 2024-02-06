class CreateCustomerOrderStatuses < ActiveRecord::Migration[6.0]
  def up
    remove_column :customer_orders, :order_status
    create_table :customer_order_statuses do |t|
      t.integer :system_order_status, null: false, default: 0
      t.integer :customer_order_status, null: false, default: 0
      t.integer :admin_order_status, null: false, default: 0
      t.integer :sales_representative_order_status, null: false, default: 0
      t.integer :partner_order_status, null: false, default: 0
      t.references :customer_order, foreign_key: true, null: false

      t.timestamps
    end
  end

  def down
    add_column :customer_orders, :order_status, :integer
    drop_table :customer_order_statuses
  end
end
