class AddPreferredDeliveryDateToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :preferred_delivery_date, :date
  end
end
