class CreateSupplierVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :supplier_variants do |t|
      t.integer :variant_id
      t.integer :supplier_id
      t.decimal :supplier_price, precision: 10, scale: 2, default: 0.0
      t.timestamps
    end
  end
end
