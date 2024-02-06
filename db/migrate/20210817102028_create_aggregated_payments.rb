class CreateAggregatedPayments < ActiveRecord::Migration[6.0]
  def change
    create_table :aggregated_payments do |t|
      t.integer :payment_type, default: 0

      t.timestamps
    end
  end
end
