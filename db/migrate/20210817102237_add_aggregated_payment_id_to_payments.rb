class AddAggregatedPaymentIdToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :aggregated_payment_id, :integer
  end
end
