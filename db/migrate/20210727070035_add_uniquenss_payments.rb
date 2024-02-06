class AddUniquenssPayments < ActiveRecord::Migration[6.0]
  def change
    add_index :payments, %i(paymentable_type paymentable_id receiver_type receiver_id customer_order_id), unique: true,
              name: 'uniq_payment'
  end
end
