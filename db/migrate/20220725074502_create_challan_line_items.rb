class CreateChallanLineItems < ActiveRecord::Migration[6.0]
  def change
    create_table :challan_line_items do |t|
      t.bigint :challan_id, null: false
      t.bigint :order_id, null: false
      t.integer :status, null: false, default: 0
      t.datetime :received_at
      t.bigint :received_by_id
      t.timestamps
    end
  end
end
