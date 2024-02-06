class CustomizeStockChangeUniqueIndex < ActiveRecord::Migration[6.0]
  def up
    remove_index :stock_changes, name: 'uniq_stock_change'
    add_index :stock_changes, %i(stock_changeable_id stock_changeable_type stock_transaction_type warehouse_variant_id),
              unique: true, where: "(stock_transaction_type NOT IN (5, 10, 15, 17, 18, 19, 20))", name: 'uniq_stock_change'
  end

  def down
    remove_index :stock_changes, name: 'uniq_stock_change'
    add_index :stock_changes, %i(stock_changeable_id stock_changeable_type stock_transaction_type warehouse_variant_id),
              unique: true, where: "(stock_transaction_type NOT IN (5, 17, 18, 19, 20))", name: 'uniq_stock_change'
  end
end
