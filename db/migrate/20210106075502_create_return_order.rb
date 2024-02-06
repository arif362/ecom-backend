class CreateReturnOrder < ActiveRecord::Migration[6.0]
  def change
    create_table :return_orders do |t|
      t.integer :return_status, default: 0
      t.references :customer_order, null: false, foreign_key: true
      t.references :partner, null: false, foreign_key: true
    end
  end
end
