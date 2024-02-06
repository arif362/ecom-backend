class AddColsToBankTransactions < ActiveRecord::Migration[6.0]
  def change
    remove_column :bank_transactions, :bank_account_id, :integer
    add_reference :bank_transactions, :debit_bank_account, foreign_key: { to_table: :bank_accounts }
    add_reference :bank_transactions, :credit_bank_account, foreign_key: { to_table: :bank_accounts }
  end
end
