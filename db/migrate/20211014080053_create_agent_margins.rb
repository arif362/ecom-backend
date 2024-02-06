class CreateAgentMargins < ActiveRecord::Migration[6.0]
  def change
    create_table :agent_margins do |t|
      t.references :customer_order, foreign_key: true, null: false
      t.references :warehouse, foreign_key: true, null: false
      t.decimal :amount
      t.string :payable_type
      t.integer :payable_id
      t.datetime :paid_at
      t.boolean :is_commissionable
      t.timestamps
    end
  end
end
