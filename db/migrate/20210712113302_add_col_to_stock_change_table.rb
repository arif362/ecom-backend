class AddColToStockChangeTable < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_changes, :quantity, :integer, default: 0
    add_column :stock_changes, :stock_transaction_reason, :string, default: ''
    add_column :stock_changes, :garbage_quantity, :integer, default: 0
  end
end
