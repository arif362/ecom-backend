class AddRiderRefToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_reference :customer_orders, :rider, index: true
  end
end
