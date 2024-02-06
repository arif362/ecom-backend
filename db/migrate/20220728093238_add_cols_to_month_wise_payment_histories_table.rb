class AddColsToMonthWisePaymentHistoriesTable < ActiveRecord::Migration[6.0]
  def change
    add_column :month_wise_payment_histories, :distributor_id, :integer
    add_column :month_wise_payment_histories, :agent_commission, :decimal, default: 0.0
    add_column :month_wise_payment_histories, :total_collection, :decimal, default: 0.0
  end
end
