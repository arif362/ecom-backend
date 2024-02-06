class AddCustomerOrderRefToPayments < ActiveRecord::Migration[6.0]
  def change
    add_reference :payments, :customer_order, foreign_key: true
  end
end
