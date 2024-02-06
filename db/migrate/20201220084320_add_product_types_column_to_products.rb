class AddProductTypesColumnToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :is_trending, :boolean, default: false
    add_column :products, :is_daily_deals, :boolean, default: false
    add_column :products, :is_new_arrival, :boolean, default: false
    add_column :products, :is_best_selling, :boolean, default: false
    remove_column :products, :product_type, :integer
  end
end
