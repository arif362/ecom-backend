class CreateBankAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_accounts do |t|
      t.string :title, null: false
      t.string :bank_name, null: false
      t.string :account_name, null: false
      t.integer :account_number, null: false
      t.string :branch_name, null: false
      t.string :ownerable_type
      t.integer :ownerable_id
      t.string :note
      t.timestamps
    end
  end
end
