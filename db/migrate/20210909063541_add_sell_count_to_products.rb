class AddSellCountToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :sell_count, :integer, default: 0, index: true
  end
end
