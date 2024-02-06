class AddColumnsInPartnerAndCustomerOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :partner_id, :bigint
    add_column :customer_orders, :shipping_type, :integer, default: 0
    add_column :partners, :schedule, :integer, default: 0
  end
end
