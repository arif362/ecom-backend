class AddBillingAndShippingAddressToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_reference :customer_orders, :billing_address, index: true
    add_reference :customer_orders, :shipping_address, index: true
  end
end
