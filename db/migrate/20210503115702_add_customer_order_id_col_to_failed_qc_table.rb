class AddCustomerOrderIdColToFailedQcTable < ActiveRecord::Migration[6.0]
  def change
    add_column :failed_qcs, :customer_order_id, :integer
    change_column_null(:failed_qcs, :variant_id, true)
  end
end
