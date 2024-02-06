class AddReturnedColCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :return_coupon, :boolean, default: false
  end
end
