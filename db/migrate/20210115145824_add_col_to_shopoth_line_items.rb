class AddColToShopothLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :shopoth_line_items, :discount_amount, :decimal, default: 0.0, precision: 10, scale: 2
    add_column :shopoth_line_items, :sub_total, :decimal, default: 0.0, precision: 10, scale: 2
  end
end
