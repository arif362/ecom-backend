class AddFinanceReceivedAtColToBankTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_transactions, :finance_received_at, :datetime
  end
end
