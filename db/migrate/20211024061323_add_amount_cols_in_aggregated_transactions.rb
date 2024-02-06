class AddAmountColsInAggregatedTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :aggregated_transactions, :total_amount, :float, default: 0.0
    add_column :aggregated_transactions, :adjustment_amount, :float, default: 0.0
    add_column :aggregated_transactions, :transactional_amount, :float, default: 0.0
  end
end
