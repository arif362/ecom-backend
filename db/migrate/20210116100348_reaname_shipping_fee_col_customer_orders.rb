class ReanameShippingFeeColCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    rename_column :customer_orders, :shipping_fee, :shipping_charge
  end
end
