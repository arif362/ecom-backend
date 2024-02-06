class CreateAggregateReturns < ActiveRecord::Migration[6.0]
  def change
    create_table :aggregate_returns do |t|
      t.decimal :sub_total, precision: 10, scale: 2, default: 0
      t.decimal :grand_total, precision: 10, scale: 2, default: 0
      t.decimal :pick_up_charge, precision: 10, scale: 2, default: 0
      t.boolean :refunded, default: false
      t.references :customer_order, foreign_key: true, null: false
      t.timestamps
    end
  end
end
