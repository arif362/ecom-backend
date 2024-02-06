class RefactorAggregateReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :aggregate_returns, :warehouse_id, :integer
    add_column :aggregate_returns, :rider_id, :integer
    add_column :aggregate_returns, :reschedule_date, :datetime
  end
end
