class ChangeDefaultPartnerIdToReturnCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    change_column_null :return_customer_orders, :partner_id, :true
  end
end
