class AddColsToProductsAndShopothLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :max_quantity_per_order, :integer, default: 100
    add_column :shopoth_line_items, :product_quantity_limit, :integer
  end
end
