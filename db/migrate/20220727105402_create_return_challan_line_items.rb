class CreateReturnChallanLineItems < ActiveRecord::Migration[6.0]
  def change
    create_table :return_challan_line_items do |t|
      t.bigint :return_challan_id, null: false
      t.bigint :orderable_id, null: false
      t.string :orderable_type, null: false
      t.integer :status, null: false, default: 0
      t.datetime :received_at
      t.bigint :received_by_id
      t.timestamps
    end
  end
end
