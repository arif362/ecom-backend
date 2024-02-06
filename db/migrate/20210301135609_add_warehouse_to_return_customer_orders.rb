class AddWarehouseToReturnCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_reference :return_customer_orders, :warehouse, foreign_key: true
  end
end
