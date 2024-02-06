class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.decimal :currency_amount, precision: 10, scale: 2, null: false
      t.string :currency_type, null: false
      t.integer :status, null: false, default: 0
      t.references :customer_order, foreign_key: true, null: false

      t.timestamps
    end
  end
end
