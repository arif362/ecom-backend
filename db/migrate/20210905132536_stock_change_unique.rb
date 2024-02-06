class StockChangeUnique < ActiveRecord::Migration[6.0]
  def change
    add_index :stock_changes, %i(stock_changeable_id stock_changeable_type stock_transaction_type warehouse_variant_id),
              unique: true, where: "(stock_transaction_type NOT IN (5, 17, 18))", name: 'uniq_stock_change'
  end
end
