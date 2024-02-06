class CreateBankTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_transactions do |t|
      t.integer :bank_account_id, null: false
      t.integer :amount, null: false
      t.string :transactionable_for_type
      t.integer :transactionable_for_id
      t.string :transactionable_by_type
      t.integer :transactionable_by_id
      t.string :transactionable_to_type
      t.integer :transactionable_to_id

      t.timestamps
    end
  end
end
