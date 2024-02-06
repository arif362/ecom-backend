class AddPartnerCommissionToCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :partner_commission, :decimal, default: 0.0
  end
end
