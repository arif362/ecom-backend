class AddCancellationReasonToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :cancellation_reason, :text
  end
end
