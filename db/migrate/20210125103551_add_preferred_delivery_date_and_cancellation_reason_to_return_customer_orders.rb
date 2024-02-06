class AddPreferredDeliveryDateAndCancellationReasonToReturnCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :return_customer_orders, :preferred_delivery_date, :date
    add_column :return_customer_orders, :cancellation_reason, :text
  end
end
