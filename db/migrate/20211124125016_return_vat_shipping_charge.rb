class ReturnVatShippingCharge < ActiveRecord::Migration[6.0]
  def change
    add_column :aggregate_returns, :vat_shipping_charge,
               :decimal, default: 0.0, precision: 8, scale: 2
  end
end
