class CreateStockChanges < ActiveRecord::Migration[6.0]
  def change
    create_table :stock_changes do |t|
      t.integer :available_quantity, default: 0
      t.integer :booked_quantity, default: 0
      t.integer :packed_quantity, default: 0
      t.integer :in_transit_quantity, default: 0
      t.integer :in_partner_quantity, default: 0
      t.integer :blocked_quantity, default: 0
      t.integer :warehouse_variant_id, null: false
      t.integer :stock_changeable_id, null: false
      t.string :stock_changeable_type, null: false

      t.timestamps
    end
  end
end
