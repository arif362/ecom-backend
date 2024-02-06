class ChangeBillingAndShippingAddressAsNotNullToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    change_column_null :customer_orders, :billing_address_id, null: false
    change_column_null :customer_orders, :shipping_address_id, null: false
  end
end
