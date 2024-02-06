class DropCustomerOrderStatus < ActiveRecord::Migration[6.0]
  def up
    drop_table :customer_order_statuses
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
