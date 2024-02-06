class AddColsToBankTransactionTable < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_transactions, :chalan_no, :string, default: ''
    add_column :bank_transactions, :is_approved, :boolean, default: false
  end
end
