class AddCustomerToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_reference :customer_orders, :customer,
                  polymorphic: true, index: true
  end
end
