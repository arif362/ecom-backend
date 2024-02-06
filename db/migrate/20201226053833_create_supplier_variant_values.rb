class CreateSupplierVariantValues < ActiveRecord::Migration[6.0]
  def change
    create_table :supplier_variant_values do |t|
      t.integer :variant_id, null: false
      t.integer :supplier_variant_id
      t.decimal :supplier_price, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end
  end
end
