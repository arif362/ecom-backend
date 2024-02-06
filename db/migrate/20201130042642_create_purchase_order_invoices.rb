class CreatePurchaseOrderInvoices < ActiveRecord::Migration[6.0]
  def change
    create_table :purchase_order_invoices do |t|
      t.integer :purchase_order_id
      t.string :purchase_order_type
      t.text :order_to
      t.text :order_from
      t.string :status
      t.timestamps
    end
  end
end
