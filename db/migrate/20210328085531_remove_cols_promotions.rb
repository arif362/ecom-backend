class RemoveColsPromotions < ActiveRecord::Migration[6.0]
  def change
    remove_column :promotions, :coupons, :integer
    remove_column :promotions, :buy_x_qty, :integer
    remove_column :promotions, :get_y_qty, :integer
  end
end
