class CreateMonthWisePaymentHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :month_wise_payment_histories do |t|
      t.integer :warehouse_id
      t.integer :month
      t.integer :year
      t.float :fc_total_collection
      t.float :fc_commission
      t.float :partner_commission

      t.timestamps
    end
  end
end
