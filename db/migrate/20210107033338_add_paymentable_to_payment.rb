class AddPaymentableToPayment < ActiveRecord::Migration[6.0]
  def change
    add_reference :payments, :paymentable, polymorphic: true, null: false
  end
end
