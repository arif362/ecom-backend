class AddColumnsToPaymentTable < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :dh_paid_to_finance, :boolean, default: false
    add_column :payments, :finance_paid_to_dh, :boolean, default: false
  end
end
