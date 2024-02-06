class AddLineItemIdToFailedQcTable < ActiveRecord::Migration[6.0]
  def change
    add_column :failed_qcs, :line_item_id, :integer
  end
end
