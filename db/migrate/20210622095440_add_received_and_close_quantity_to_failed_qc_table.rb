class AddReceivedAndCloseQuantityToFailedQcTable < ActiveRecord::Migration[6.0]
  def change
    add_column :failed_qcs, :received_quantity, :integer, default: 0
    add_column :failed_qcs, :closed_quantity, :integer, default: 0
  end
end
