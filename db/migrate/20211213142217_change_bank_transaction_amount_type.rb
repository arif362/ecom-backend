class ChangeBankTransactionAmountType < ActiveRecord::Migration[6.0]
  def change
    change_column(:bank_transactions, :amount, :decimal)
  end
end
