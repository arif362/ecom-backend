class CreateDistributorMargins < ActiveRecord::Migration[6.0]
  def change
    create_table :distributor_margins do |t|
      t.integer :customer_order_id, null: false
      t.integer :distributor_id, null: false
      t.integer :payable_id
      t.string :payable_type
      t.datetime :paid_at
      t.boolean :is_commissionable
      t.decimal :amount, default: 0.0

      t.timestamps
    end
  end
end
