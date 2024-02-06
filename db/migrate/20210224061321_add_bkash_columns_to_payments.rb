class AddBkashColumnsToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :bkash_payment_id, :string
    add_column :payments, :bkash_transaction_status, :string
  end
end
