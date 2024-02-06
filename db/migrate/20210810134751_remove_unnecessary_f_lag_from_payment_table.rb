class RemoveUnnecessaryFLagFromPaymentTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :payments, :dh_paid_to_finance, :boolean
    remove_column :payments, :finance_paid_to_dh, :boolean
  end
end
