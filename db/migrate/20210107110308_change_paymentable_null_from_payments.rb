class ChangePaymentableNullFromPayments < ActiveRecord::Migration[6.0]
  def change
    change_column_null :payments, :paymentable_type, true
    change_column_null :payments, :paymentable_id, true
  end
end
