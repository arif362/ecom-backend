class AddRouteAndRiderIdToCustomerOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :next_shipping_type, :integer
    add_column :customer_orders, :next_partner_id, :integer
  end
end
