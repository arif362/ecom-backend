class CreateBlockedItems < ActiveRecord::Migration[6.0]
  def change
    create_table :blocked_items do |t|
      t.integer :warehouse_id
      t.integer :variant_id
      t.integer :blocked_quantity, default: 0
      t.integer :garbage_quantity, default: 0
      t.integer :unblocked_quantity, default: 0
      t.integer :blocked_reason
      t.text :note
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
