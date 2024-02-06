class CreateWallet < ActiveRecord::Migration[6.0]
  def change
    create_table :wallets do |t|
      t.decimal :currency_amount, precision: 10, scale: 2, null: false
      t.string :currency_type, null: false
      t.references :walletable, polymorphic: true, null: false
    end
  end
end
