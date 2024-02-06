class AggregateReturnCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :aggregate_return_id, :integer
  end
end
