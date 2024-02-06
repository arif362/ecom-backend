class CreateInvoices < ActiveRecord::Migration[6.0]
  def change
    create_table :invoices do |t|
      t.references :customer_order, null: false, foreign_key: true
    end
  end
end
