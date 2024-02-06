class RemoveLogisticsIdFromPo < ActiveRecord::Migration[6.0]
  def change
    remove_column :dh_purchase_orders, :logistic_id, :integer
    remove_column :wh_purchase_orders, :logistic_id, :integer
  end
end
