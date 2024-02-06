class AddColumnsToAggregatedTransaction < ActiveRecord::Migration[6.0]
  def change
    add_column :aggregated_transactions, :month, :integer, default: 0
    add_column :aggregated_transactions, :year, :integer
  end
end
