class AddCashCollectedToRiders < ActiveRecord::Migration[6.0]
  def change
    add_column :riders, :cash_collected, :decimal, default: 0
  end
end
