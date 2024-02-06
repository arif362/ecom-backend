class AddColumnWarehouseIdToFailedQc < ActiveRecord::Migration[6.0]
  def change
    add_column :failed_qcs, :warehouse_id, :integer
  end
end
