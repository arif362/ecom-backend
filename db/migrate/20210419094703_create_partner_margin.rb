class CreatePartnerMargin < ActiveRecord::Migration[6.0]
  def change
    create_table :partner_margins do |t|
      t.integer :customer_order_id, null: false, foreign_key: true
      t.integer :partner_id, null: false, foreign_key: true
      t.string :order_type, null: false
      t.integer :payment_id
      t.decimal :amount, precision: 10, scale: 2, default: 0.0, null: false

      t.timestamps
    end
  end
end
