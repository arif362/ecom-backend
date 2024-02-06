class AddReturnCountToWarehouses < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouses, :return_count, :integer, default: 0
  end
end
