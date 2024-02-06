class AddPayableAmountAndReturnAmountInPaymentHistories < ActiveRecord::Migration[6.0]
  def change
    add_column :month_wise_payment_histories, :payable_amount, :float, default: 0.0
    add_column :month_wise_payment_histories, :return_amount, :float, default: 0.0
  end
end
