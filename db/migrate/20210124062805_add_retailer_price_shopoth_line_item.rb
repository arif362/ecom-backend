class AddRetailerPriceShopothLineItem < ActiveRecord::Migration[6.0]
  def change
    add_column :shopoth_line_items, :retailer_price, :decimal, default: 0.0, precision: 10, scale: 2
  end
end
