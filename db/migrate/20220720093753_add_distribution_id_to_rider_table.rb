class AddDistributionIdToRiderTable < ActiveRecord::Migration[6.0]
  def change
    add_column :riders, :distributor_id, :integer
  end
end
