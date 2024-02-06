class RemoveCustomerOrderIdFromPayments < ActiveRecord::Migration[6.0]
  def change
    remove_column :payments, :customer_order_id, :bigint
  end
end
