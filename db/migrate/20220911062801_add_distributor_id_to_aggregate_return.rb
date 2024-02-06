class AddDistributorIdToAggregateReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :aggregate_returns, :distributor_id, :integer
  end
end
