class CreateAggregatedTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :aggregated_transactions do |t|
      t.integer :transaction_type, default: 0

      t.timestamps
    end
  end
end
