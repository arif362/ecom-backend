class AddDestributorIdToRoutes < ActiveRecord::Migration[6.0]
  def change
    add_column :routes, :distributor_id, :integer
  end
end
