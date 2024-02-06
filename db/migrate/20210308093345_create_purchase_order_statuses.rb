class CreatePurchaseOrderStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :purchase_order_statuses do |t|
      t.string :orderable_type
      t.integer :orderable_id
      t.string :status
      t.timestamps
    end
  end
end
