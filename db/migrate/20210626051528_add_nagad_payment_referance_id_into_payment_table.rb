class AddNagadPaymentReferanceIdIntoPaymentTable < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :nagad_payment_reference_id, :string, default: nil
  end
end
