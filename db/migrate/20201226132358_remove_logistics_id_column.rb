class RemoveLogisticsIdColumn < ActiveRecord::Migration[6.0]
  def change
    remove_column :dh_purchase_orders, :logistics_id, :integer
    remove_column :wh_purchase_orders, :logistics_id, :integer
  end
end
