class AddColToCarts < ActiveRecord::Migration[6.0]
  def change
    add_column :carts, :sub_total, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :carts, :shopoth_line_item_discounts, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :carts, :cart_discount, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :carts, :total_discount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
