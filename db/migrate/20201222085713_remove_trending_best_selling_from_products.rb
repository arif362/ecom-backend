class RemoveTrendingBestSellingFromProducts < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :is_trending, :boolean
    remove_column :products, :is_daily_deals, :boolean
    remove_column :products, :is_new_arrival, :boolean
    remove_column :products, :is_best_selling, :boolean
  end
end
