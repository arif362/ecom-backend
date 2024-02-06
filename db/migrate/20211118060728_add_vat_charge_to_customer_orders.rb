class AddVatChargeToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :vat_shipping_charge, :decimal,
               precision: 8, scale: 2, default: 0.0
  end
end
