class AddDefaultCurrencyAmountToWallets < ActiveRecord::Migration[6.0]
  def change
    change_column_default :wallets, :currency_amount, from: nil, to: 0.0
  end
end
