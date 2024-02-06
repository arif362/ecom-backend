class CreateAggregatedTransactionCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :aggregated_transaction_customer_orders do |t|
      t.integer :aggregated_transaction_id, null: false
      t.integer :customer_order_id, null: false
      t.integer :amount, null: false
      t.integer :transaction_type, default: 0

      t.timestamps
    end
  end
end
