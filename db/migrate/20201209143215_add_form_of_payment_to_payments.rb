class AddFormOfPaymentToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :form_of_payment, :integer, default: 0, null: false
  end
end
