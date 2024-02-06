class AddAttributeCustomerOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :adjustment_total, :decimal, default: 0.0
    add_column :customer_orders, :total_price, :decimal, default: 0.0
  end
end
