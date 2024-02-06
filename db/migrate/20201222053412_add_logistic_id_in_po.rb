class AddLogisticIdInPo < ActiveRecord::Migration[6.0]
  def change
    add_column :wh_purchase_orders, :logistic_id, :integer, null: false
    add_column :dh_purchase_orders, :logistic_id, :integer, null: false
  end
end
