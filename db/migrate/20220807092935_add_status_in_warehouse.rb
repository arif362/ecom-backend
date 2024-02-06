class AddStatusInWarehouse < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouses, :status, :integer, default: 0
  end
end
