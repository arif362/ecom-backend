class PaymentReferenceIdInPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :payment_reference_id, :string, default: ''
  end
end
